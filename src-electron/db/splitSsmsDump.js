const fs = require("fs");
const path = require("path");

const REPEATABLE_DIR = path.join(__dirname, "repeatable");
const OBJECT_SPLIT = /\r?\n(?=\/\*{6} Object:\s+StoredProcedure)/i;

function readDump(absPath) {
  const buf = fs.readFileSync(absPath);
  if (buf.length >= 2 && buf[0] === 0xff && buf[1] === 0xfe) {
    return buf.slice(2).toString("utf16le");
  }
  if (buf.length >= 2 && buf[0] === 0xfe && buf[1] === 0xff) {
    return buf.swap16().slice(2).toString("utf16le");
  }
  if (buf.length >= 3 && buf[0] === 0xef && buf[1] === 0xbb && buf[2] === 0xbf) {
    return buf.slice(3).toString("utf8");
  }
  if (buf.includes(0x00)) {
    return buf.toString("utf16le");
  }
  return buf.toString("utf8");
}

function stripUseDatabase(sql) {
  return String(sql || "")
    .replace(/^\uFEFF/, "")
    .replace(/^\s*USE\s+\[[^\]]+\]\s*\r?\nGO\s*\r?\n/i, "")
    .replace(/^\s*USE\s+\S+\s*\r?\nGO\s*\r?\n/i, "")
    .trim();
}

function extractProcName(chunk) {
  const objectMatch = chunk.match(
    /Object:\s+StoredProcedure\s+\[(?:dbo)\]\.\[([^\]]+)\]/i
  );
  if (objectMatch) return objectMatch[1];

  const createMatch = chunk.match(
    /CREATE\s+PROCEDURE\s+(?:\[dbo\]\.)?\[?([^\s\]\.(]+)/i
  );
  if (createMatch) return createMatch[1];
  return null;
}

function toCreateOrAlter(chunk) {
  return chunk.replace(
    /\bCREATE\s+PROCEDURE\b/gi,
    "CREATE OR ALTER PROCEDURE"
  );
}

function splitDump(dumpText) {
  const cleaned = stripUseDatabase(dumpText);
  const chunks = cleaned
    .split(OBJECT_SPLIT)
    .map((c) => stripUseDatabase(c))
    .filter(Boolean);

  const files = [];
  for (const chunk of chunks) {
    const name = extractProcName(chunk);
    if (!name) {
      throw new Error(
        `No se pudo leer el nombre del SP en un bloque:\n${chunk.slice(0, 180)}`
      );
    }
    let body = toCreateOrAlter(chunk).trim();
    if (!/\bGO\s*$/i.test(body)) body += "\nGO";
    const header = `/*\n  Product SP: ${name}\n  Repeatable migrator: CREATE OR ALTER (checksum)\n*/\n`;
    files.push({
      name,
      fileName: `R__${name}.sql`,
      content: `${header}${body}\n`,
    });
  }
  return files;
}

function writeRepeatableFiles(files, targetDir) {
  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
  }
  const written = [];
  for (const file of files) {
    const dest = path.join(targetDir, file.fileName);
    fs.writeFileSync(dest, file.content, "utf8");
    written.push(file.fileName);
  }
  return written;
}

function main() {
  const input = process.argv[2];
  if (!input) {
    console.error(
      "Uso: node src-electron/db/splitSsmsDump.js <ruta-al-dump.sql>"
    );
    process.exit(1);
  }
  const abs = path.resolve(input);
  if (!fs.existsSync(abs)) {
    console.error("No existe el archivo:", abs);
    process.exit(1);
  }
  const dump = readDump(abs);
  const files = splitDump(dump);
  const names = files.map((f) => f.name);
  const dupes = names.filter((n, i) => names.indexOf(n) !== i);
  if (dupes.length) {
    console.error("SP duplicados en el dump:", [...new Set(dupes)].join(", "));
    process.exit(1);
  }
  const written = writeRepeatableFiles(files, REPEATABLE_DIR);
  console.log(`Escritos ${written.length} SP en ${REPEATABLE_DIR}`);
  written.forEach((name) => console.log("  " + name));
}

if (require.main === module) {
  main();
}

module.exports = { splitDump, writeRepeatableFiles };
