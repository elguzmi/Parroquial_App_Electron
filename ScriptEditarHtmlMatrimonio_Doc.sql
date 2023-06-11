
update Dim_Documentos set Parametros = '@Novio|@Novia|@Libro|@Folio|@Numero|@Fecha_Matrimonio|@Presencio|@Padres_Novio|@Parroquia_Novio|@Fecha_Bautismo_Novio|@Libro_Novio|@Folio_Novio|@Acta_Novio|@Padres_Novia|@Parroquia_Novia|@Fecha_Bautismo_Novia|@Libro_Novia|@Folio_Novia|@Acta_Novia|@Testigos|@DoyFe|@Nota_Marginal|@Firmante|@cargo'
where Id_Documento = 3

--select * from Fact_Matrimonios

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
    <span style="font-size: 25px; font-weight: 700">ACTA DE MATRIMONIO</span
    ><br />
    <span style="font-size: 25px; font-weight: 700">@Novio</span><br>
    <span style="font-size: 25px; font-weight: 700">Y</span><br>
    <span style="font-size: 25px; font-weight: 700">@Novia</span>
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
          <td style="text-align: left">En la parroquia</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">JESÚS EUCARISTÍA</td>
        </tr>
        <tr>
          <td style="text-align: left">El día</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Fecha_Matrimonio</td>
        </tr>
        <tr>
          <td style="text-align: left">Ministro</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Presencio</td>
        </tr>
        <tr>
          <td style="text-align: left" colspan="3"><b> DATOS DEL CONTRAYENTE </b></td>
        </tr>
        <tr>
          <td style="text-align: left " >Nombres y apellidos</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left ; font-weight: 700" colspan="2">@Novio</td>
        </tr>
        <tr>
          <td style="text-align: left">Hijo de</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Padres_Novio</td>
        </tr>
        <tr>
          <td style="text-align: left">Parroquia de bautismo</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Parroquia_Novio</td>
        </tr>
        <tr>
          <td style="text-align: left">Fecha de bautismo</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Fecha_Bautismo_Novio</td>
        </tr>
        <tr>
          <td style="text-align: left"></td>
          <td style="text-align: left"></td>
          <td style="text-align: left" colspan="2" style="text-align: left">
            <span>Libro : @Libro_Novio </span><span>Folio :@Folio_Novio </span
            ><span>Acta: @Acta_Novio</span>
          </td>
        </tr>
        <tr>
          <td style="text-align: left" colspan="3"><b>DATOS DE LA CONTRAYENTE</b></td>
        </tr>
        <tr>
          <td style="text-align: left ">Nombres y apellidos</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left ; font-weight: 700" colspan="2">@Novia</td>
        </tr>
        <tr>
          <td style="text-align: left">Hijo de</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Padres_Novia</td>
        </tr>
        <tr>
          <td style="text-align: left">Parroquia de bautismo</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Parroquia_Novia</td>
        </tr>
        <tr>
          <td style="text-align: left">Fecha de bautismo</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Fecha_Bautismo_Novia</td>
        </tr>
        <tr>
          <td style="text-align: left"></td>
          <td style="text-align: left"></td>
          <td style="text-align: left" colspan="2" style="text-align: left">
            <span><b>Libro :</b>  @Libro_Novia   </span>
			&nbsp&nbsp<span><b>Folio :</b> @Folio_Novia </span>
			&nbsp&nbsp<span><b>Acta :</b> @Acta_Novia</span>
          </td>
        </tr>
        <tr>
          <td style="text-align: left">Testigos</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@Testigos</td>
        </tr>
        <tr>
          <td style="text-align: left">Doy fe</td>
          <td style="text-align: left">:</td>
          <td style="text-align: left" colspan="2">@DoyFe</td>
        </tr>
        <tr>
          <td style="text-align: left" colspan="3"><b>Nota Marginal</b></td>
        </tr>
        <tr style="text-align: justify">
          <td colspan="3">@Nota_Marginal</td>
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
where Id_Documento = 3


update a
set Html_Header = '<div class="header" style="font-family: Arial, Helvetica, sans-serif;font-size: 18px;margin-top:3px">  <div style="width: 100%; text-align: center;line-height: 8px;" class="title">        <p style="font-size: 24px;font-weight: 700;">@NombreLocal</p>        <p style="font-weight: 700;">@Parroquia</p>        <p> @Direccion Cel.@Cel</p>        <p>Correo: @Correo</p>        <p> @Ciudad </p>      </div>  </div>'
-- select * 
from Dim_Documentos a
where Id_Documento = 3


update a
set Html_Footer = ' <div class="footer" style="width:80%;margin: 0 auto;border-top:1px solid black;font-size: 15px; text-align: center; line-height: 16px;font-family: Arial, Helvetica, sans-serif"    >      Autenticación en la curia Diocesana de Fontibón, Carrera 98 # 17 A - 81      Fontibón - Centro. <br />      Tel 4181036, Horario de atención, Lunes a Viernes de 9:00 a 1:00 P.M      (Validez a 3 Meses)    </div>'
-- select * 
from Dim_Documentos a
where Id_Documento = 3
