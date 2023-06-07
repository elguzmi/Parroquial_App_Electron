
--update Dim_Documentos set Parametros = '@Nombre_Confirmado|@Libro|@Folio|@Numero|@Fecha_Confirmacion|@Ministro|@Nombre_Confirmado|@Lugar_Nacimiento|@Fecha_Nacimiento|@Nombre_Padres|@Parroquia_Bautizo|@Fecha_Bautismo|@Diocesis|@Libro_B|@Folio_B|@Numero_B|@Padrinos|@Notas_Correcciones|@Firmante|@cargo'
--where Id_Documento = 2

--select * from Fact_Confirmaciones

update a
set Html_Body = '
 <div
    class="body"
    style="
      text-align: center;
      margin-top: 70px;
      font-family: Arial, Helvetica, sans-serif;
      font-size: 18px;
    "
  >
    <br />
    <span style="font-size: 25px; font-weight: 700">ACTA DE CONFIRMACIÓN</span
    ><br />
    <span style="font-size: 20px; font-weight: 700">@Nombre_Confirmado</span>
    <div>
      <span style="text-align: left; display: inline-block; width: 150px"
        >Libro : @Libro
      </span>
      <span style="text-align: left; display: inline-block; width: 150px"
        >Folio : @Folio
      </span>
      <span style="text-align: left; display: inline-block; width: 150px"
        >Numero : @Numero
      </span>
    </div>
    <br />
    <div style="width: 70%; margin: 0 auto">
      <table
        border="0"
        style="
          border-collapse: collapse;
          width: 90%;
          text-align: left;
          line-height: 26px;
          margin-left: 40px;
        "
      >
        <tr>
          <td style="text-align: left">Parroquia de confirmación</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">JESÚS EUCARISTÍA</td>
        </tr>
        <tr>
          <td style="text-align: left">Fecha de confirmación</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Fecha_Confirmacion</td>
        </tr>
        <tr>
          <td style="text-align: left">Ministro</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Ministro</td>
        </tr>
        <tr>
          <td style="text-align: left">Confirmó a</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Nombre_Confirmado</td>
        </tr>
        <tr>
          <td style="text-align: left">Lugar de nacimiento</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Lugar_Nacimiento</td>
        </tr>
        <tr>
          <td style="text-align: left">Fecha de nacimiento</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Fecha_Nacimiento</td>
        </tr>
        <tr>
          <td style="text-align: left">Hijo(a) de</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Nombre_Padres</td>
        </tr>
        <tr>
          <td style="text-align: left">Parroquia de bautismo</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Parroquia_Bautizo</td>
        </tr>
        <tr>
          <td style="text-align: left">Diocesis de bautismo</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Diocesis</td>
        </tr>
        <tr>
          <td style="text-align: left">Fecha de bautismo</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Fecha_Bautismo</td>
        </tr>
		<tr>
          <td style="text-align: left"></td>
          <td style="text-align: left"></td>
          <td style="text-align: left" colspan="2"><span>Libro : @Libro_B</span> <span>Folio : @Folio_B</span><span>Numero : @Numero_B</span></td>
        </tr>
		<tr>
          <td style="text-align: left">Padrino o Madrina</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Padrinos</td>
        </tr>
		 <tr>
          <td style="text-align: left">Notas Marginales</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Notas_Correcciones</td>
        </tr>
		 <tr>
          <td colspan="4">
            <br /><br /><br /><br /><br />
            @ExpedidoEn
          </td>
        </tr>
      </table>
      <div style="width: 90%; margin-top: 80px; text-align: right">
        <div style="width: 40%; float: right">
          <div
            style="
              display: block;
              border-bottom: 1px solid black;
              width: 100%;
              margin: 0 auto;
              height: 10px;
            "
          ></div>
          <br />
          <div style="width: 100%; text-align: center">
            @Firmante <br />
            @Cargo
          </div>
        </div>
      </div>
    </div>
  </div>
'
-- select * 
from Dim_Documentos a
where Id_Documento = 2


update a
set Html_Header = '<div class="header" style="font-family: Arial, Helvetica, sans-serif;font-size: 18px;margin-top:3px">  <div style="width: 100%; text-align: center;line-height: 8px;" class="title">        <p style="font-size: 24px;font-weight: 700;">@NombreLocal</p>        <p style="font-weight: 700;">@Parroquia</p>        <p> @Direccion Cel.@Cel</p>        <p>Correo: @Correo</p>        <p> @Ciudad </p>      </div>  </div>'
-- select * 
from Dim_Documentos a
-- where Id_Documento = 2


update a
set Html_Footer = ' <div class="footer" style="width:80%;margin: 0 auto;border-top:1px solid black;font-size: 15px; text-align: center; line-height: 16px;font-family: Arial, Helvetica, sans-serif"    >      Autenticación en la curia Diocesana de Fontibón, Carrera 98 # 17 A - 81      Fontibón - Centro. <br />      Tel 4181036, Horario de atención, Lunes a Viernes de 9:00 a 1:00 P.M      (Validez a 3 Meses)    </div>'
-- select * 
from Dim_Documentos a
-- where Id_Documento = 2
