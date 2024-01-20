import {
  app,
  BrowserWindow,
  nativeTheme,
  ipcMain,
  shell,
  autoUpdater,
} from "electron";
import path from "path";
import os from "os";
const sql = require("mssql");
var fs = require("fs");

console.log(process.env.NODE_ENV);
const dataBases = {
  serverDev: { name: "GAMINGUZMI\\SERVERSANTI", selected: true },
  //serverProd: { name: "DESKTOP-6BM9I17\\SQLEXPRESS", selected: false },
  serverProd: { name: "192.168.20.27\\SQLEXPRESS", selected: false },
};
const sqlConfig = {
  user: "sa",
  password: "Minecraft123",
  server: dataBases.serverProd.name,
  database: "ParroquiaBackup",
  options: {
    encrypt: false,
  },
};

const platform = process.platform || os.platform();

let mainWindow;

function createWindow() {
  /* Initial window options*/
  mainWindow = new BrowserWindow({
    icon: path.resolve(__dirname, "icons/icon.png"), // tray icon
    width: 1300,
    height: 660,
    useContentSize: true,
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox"],
    webPreferences: {
      contextIsolation: true,
      sandbox: false,
      // More info: /quasar-cli/developing-electron-apps/electron-preload-script
      preload: path.resolve(__dirname, process.env.QUASAR_ELECTRON_PRELOAD),
      //preload: MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY,
      //preload: path.resolve(__dirname, "electron-preload.js"),
      nodeIntegration: true,
    },
  });

  mainWindow.loadURL(process.env.APP_URL);

  if (process.env.DEBUGGING) {
    // if on DEV or Production with debug enabled
    mainWindow.webContents.openDevTools();
  } else {
    // we're on production; no access to devtools pls
    mainWindow.webContents.on("devtools-opened", () => {
      mainWindow.webContents.closeDevTools();
    });
  }

  mainWindow.on("closed", () => {
    mainWindow = null;
  });
}

app.whenReady().then(createWindow);
app.on("window-all-closed", () => {
  if (platform !== "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  if (mainWindow === null) {
    createWindow();
  }
});

//#region Api login

// ********** API DE LOGIN
ipcMain.handle("ApiLogin:change_Database", async (ev, arg) => {
  try {
    sqlConfig.server = dataBases[arg].name;
    return "OK";
  } catch (err) {
    return "Error -" + err;
  }
});

// ********** API DE LOGIN
ipcMain.handle("ApiLogin:login", async (ev, arg) => {
  try {
    let { user, clave } = arg;
    let data = await sql.connect(sqlConfig);
    if (data.connected) {
      let request = new sql.Request();
      request.input("Usuario", sql.VARCHAR(50), user);
      request.input("Clave", sql.VARCHAR(50), clave);
      let exec = await request.execute("BD_Get_Login");
      await data.close();
      return exec.recordsets[0];
    }
  } catch (err) {
    return { isError: true, errorMessage: "Apilogin " + err };
  }
});

ipcMain.handle("ApiLogin:Load_Modules", async (ev, IdPerfil) => {
  try {
    let data = await sql.connect(sqlConfig);
    if (data.connected == true) {
      let request = new sql.Request();
      request.input("IdPerfil", sql.Int, IdPerfil);
      let exec = await request.execute("BD_Get_ModulosPerfil");
      await await data.close();
      return exec.recordsets[0];
    }
  } catch (err) {
    return "Load_Modules " + err;
  }
});

//#endregion

//** procedimiento  que se ejecuta y devuelve un string  */
ipcMain.handle("myAPI:executeSp_St", async (ev, data, sp) => {
  try {
    let parametersIn = null;
    parametersIn = await getParametersSp(sp);
    let arg = JSON.parse(data);
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      parametersIn.map((e) => {
        request.input(
          e["ParameterN"],
          getTypeData(e["Type"], e["max_length"]),
          arg[e["ParameterN"]]
        );
      });
      let exec = await request.execute(sp);
      await conn.close();
      return exec.recordset[0][""];
    }
  } catch (err) {
    return "Error - executeSp_St " + err;
  }
});

//** procedimiento  que se ejecuta y devuelve un array de json  */
ipcMain.handle("myAPI:executeSp_Dt", async (ev, data, sp) => {
  try {
    let parametersIn = null;
    parametersIn = await getParametersSp(sp);
    let arg = JSON.parse(data);
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      parametersIn.map((e) => {
        request.input(
          e["ParameterN"],
          getTypeData(e["Type"], e["max_length"]),
          arg[e["ParameterN"]]
        );
      });
      let exec = await request.execute(sp);
      await conn.close();
      return exec.recordset[0];
    }
  } catch (ex) {
    return "Error - executeSp_St " + err;
  }
});

//** procedimiento  que se ejecuta y devuelve varios arrays de json  */
ipcMain.handle("myAPI:executeSp_Ds", async (ev, data, sp) => {
  try {
    let parametersIn = null;
    parametersIn = await getParametersSp(sp);
    let arg = JSON.parse(data);
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      parametersIn.map((e) => {
        request.input(
          e["ParameterN"],
          getTypeData(e["Type"], e["max_length"]),
          arg[e["ParameterN"]]
        );
      });
      let exec = await request.execute(sp);
      await conn.close();
      return exec.recordsets;
    }
  } catch (ex) {
    return { isError: true, errorMessage: "executeSp_Ds " + ex };
  }
});

ipcMain.handle("myAPI:Export_Data", async (ev, tabla) => {
  try {
    if (!tabla) return "Error - No Data to search";
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      request.input("Tabla", sql.VarChar(20), tabla);
      let exec = await request.execute("BD_GetData_FromTable");
      await conn.close();
      let datos = exec.recordsets[0];
      let headers = Object.keys(datos[0]);
      let msj = await exportData(headers, datos, tabla);
      return msj;
    }
  } catch (err) {
    return { isError: true, errorMessage: "Fn_Export_Data " + err };
  }
});

ipcMain.handle("myAPI:openFilesTemplates", async (ev, tabla) => {
  try {
    //shell.showItemInFolder
    const rutaFiles =
      process.env.NODE_ENV == "development"
        ? __dirname
        : path.dirname(__dirname);

    shell.showItemInFolder(
      path.resolve(rutaFiles, "TemplateConfirmacion.docx")
    );
    return rutaFiles, "TemplateConfirmacion.docx";
  } catch (err) {
    return { isError: true, errorMessage: "openFilesTemplates " + err };
  }
});
ipcMain.handle("myAPI:convertTo_Docx", async (ev, dataHtml) => {
  const HTMLtoDOCX = require("html-to-docx");
  try {
    let { Html_Body_Docx_Node, Html_Footer_Docx_Node, Html_Header_Docx_Node } =
      JSON.parse(dataHtml);

    let data = await HTMLtoDOCX(
      Html_Body_Docx_Node,
      Html_Header_Docx_Node,
      {
        orientation: "portrait",
        header: true,
        footer: true,
        table: { row: { cantSplit: false } },
        pageSize: { width: "210mm", height: "329mm" },
        font: "Arial",
        margins: {
          top: "0mm",
          right: "16mm",
          bottom: "0mm",
          left: "20mm",
          header: "10mm",
          footer: "5mm",
          gutter: "0mm",
        },
        title: "Parroquia_Doc",
        lang: "es-co",
      },
      Html_Footer_Docx_Node
    );
    const currentDirectory = app.getAppPath();
    let route = os.homedir() + "/desktop";
    //let route = __dirname + "/" + nombre;
    fs.writeFileSync(route + "/docWordExport.docx", data);
    shell.openPath(route + "/docWordExport.docx");
    return route + "/docWordExport.docx";
  } catch (err) {
    return { isError: true, errorMessage: "convertTo_Docx " + err };
  }
});

ipcMain.handle("myAPI:convertTo_Docx_Zip", async (ev, data) => {
  const PizZip = require("pizzip");
  const Docxtemplater = require("docxtemplater");
  const cheerio = require("cheerio");

  const rutaFiles =
    process.env.NODE_ENV == "development" ? __dirname : path.dirname(__dirname);
  try {
    let obj = JSON.parse(data);
    const content = fs.readFileSync(
      path.resolve(rutaFiles, obj["Nombre_Archivo"]),
      "binary"
    );
    // Unzip the content of the file
    const zip = new PizZip(content);
    const doc = new Docxtemplater(zip, {
      paragraphLoop: true,
      linebreaks: true,
    });

    // Cargar el contenido HTML en Cheerio
    // si es confirmaciones
    if (obj["Nombre_Archivo"] == "TemplateConfirmacion.docx") {
      const textoEnCheer = cheerio.load(obj["Notas_Correcciones"]);
      const plainText = textoEnCheer.text();
      obj["Notas_Correcciones"] = plainText;
    } else if (obj["Nombre_Archivo"] == "TemplateDefuncion.docx") {
      const textoEnCheer = cheerio.load(obj["NotaMarginal"]);
      const plainText = textoEnCheer.text();
      obj["NotaMarginal"] = plainText;
    } else {
      const textoEnCheer = cheerio.load(obj["Nota_Marginal"]);
      const plainText = textoEnCheer.text();
      obj["Nota_Marginal"] = plainText;
    }
    // Obtener el texto sin etiquetas
    doc.render(obj);
    // Get the zip document and generate it as a nodebuffer
    const buf = doc.getZip().generate({
      type: "nodebuffer",
      // compression: DEFLATE adds a compression step.
      // For a 50MB output document, expect 500ms additional CPU time
      compression: "DEFLATE",
    });

    // buf is a nodejs Buffer, you can either write it to a
    // file or res.send it with express for example.
    fs.writeFileSync(
      path.resolve(rutaFiles, "output_" + obj["Nombre_Archivo"]),
      buf
    );

    shell.openPath(
      path.resolve(path.join(rutaFiles, "output_" + obj["Nombre_Archivo"]))
    );

    return { isError: false, data: "OK" };
  } catch (err) {
    return { isError: true, errorMessage: "convertTo_Docx_Zip" + err };
  }
});

// APILIST
function exportData(headers, datos, tabla) {
  return new Promise((res, rej) => {
    const xl = require("excel4node");
    const wb = new xl.Workbook();
    const ws = wb.addWorksheet("Worksheet Name");
    const data = datos;
    const headingColumnNames = headers;
    //Write Column Title in Excel file
    let headingColumnIndex = 1;
    headingColumnNames.forEach((heading) => {
      ws.cell(1, headingColumnIndex++).string(heading);
    });
    //Write Data in Excel file
    let rowIndex = 2;
    data.forEach((record) => {
      let columnIndex = 1;
      Object.keys(record).forEach((columnName) => {
        ws.cell(rowIndex, columnIndex++).string(record[columnName]);
      });
      rowIndex++;
    });
    let route = os.homedir() + "/desktop/" + tabla + "_data.xlsx";
    //wb.write("C:Users/santi/Desktop/data.xlsx");
    wb.write(route);
    res(route);
  });
}

function getParametersSp(Sp) {
  return new Promise(async (resolve) => {
    let conn = await sql.connect(sqlConfig);
    if (conn.connected == true) {
      let request = new sql.Request();
      request.input("Sp", sql.VarChar(50), Sp);
      let exec = await request.execute("BD_Get_Lists_Parameters");
      await conn.close();
      resolve(exec.recordset);
    }
  });
}

function getTypeData(dato, longitud) {
  if (dato == "int") return sql.Int;
  else if (dato == "varchar")
    return sql.VarChar(longitud == -1 ? "max" : longitud);
  else if (dato == "nvarchar")
    return sql.NVarChar(longitud == -1 ? "max" : longitud);
}
