update a
set Html_Body = '   
<div class="body" style="text-align: center; margin-top:70px;font-family: Arial, Helvetica, sans-serif;font-size: 18px;">
	</br>
    <span style="font-size: 25px; font-weight: 700">ACTA DE BAUTISMO</span></br>
    <span style="font-size: 20px; font-weight: 700">@Nombre</span>
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
    <div style="width: 100%">
      <table
        border="0"
        style="border-collapse: collapse; width: 90%; text-align: left;line-height: 24px;margin-left:50px"
      >
        <tr>
          <td style="text-align: left">En la parroquia</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">JESÚS EUCARISTÍA</td>
        </tr>
        <tr>
          <td style="text-align: left">Fecha de bautismo</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">@Fecha_Bautismo</td>
        </tr>
        <tr>
          <td style="text-align: left">Ministro</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">@Ministro</td>
        </tr>
        <tr>
          <td style="text-align: left">Nombres y apellidos</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">@Nombre</td>
        </tr>
        <tr>
          <td style="text-align: left">Lugar de nacimiento</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">@Lugar_Nacimiento</td>
        </tr>
        <tr>
          <td style="text-align: left">Fecha de nacimiento</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">@Fecha_Nacimiento</td>
        </tr>
        <tr>
          <td style="text-align: left">Hijo(a) de</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">@Padres</td>
        </tr>
        <tr>
          <td style="text-align: left">Abuelos paternos</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">@Abuelos_Paternos</td>
        </tr>
        <tr>
          <td style="text-align: left">Abuelos Maternos</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">@Abuelos_Maternos</td>
        </tr>
        <tr>
          <td style="text-align: left">Padrinos</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">@Padrinos</td>
        </tr>
        <tr>
          <td style="text-align: left">Doy Fe</td>
          <td>:</td>
          <td colspan="2" style="text-align: left">@DoyFe</td>
        </tr>
        <tr>
          <td style="text-align: left">Notas Marginales</td>
          <td>:</td>
          <td colspan="2" style="text-align: justify">@Nota_Marginal</td>
        </tr>
        <tr>
          <td colspan="4">
            <br /><br /><br /><br /><br />
            @ExpedidoEn
          </td>
        </tr>
      </table>
      <div style="width: 80%; margin-top: 80px; text-align: right;">
        <div style="width: 40%;float:right;">
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
  </div>'
-- select * 
from Dim_Documentos a
where Id_Documento = 1


update a
set Html_Header = '<div class="header" style="font-family: Arial, Helvetica, sans-serif;font-size: 18px;margin-top:3px">  <div style="width: 100%; text-align: center;line-height: 8px;" class="title">        <p style="font-size: 24px;font-weight: 700;">@NombreLocal</p>        <p style="font-weight: 700;">@Parroquia</p>        <p> @Direccion Cel.@Cel</p>        <p>Correo: @Correo</p>        <p> @Ciudad </p>      </div>  </div>'
-- select * 
from Dim_Documentos a
where Id_Documento = 1


update a
set Html_Footer = ' <div class="footer" style="width:80%;margin: 0 auto;border-top:1px solid black;font-size: 15px; text-align: center; line-height: 16px;font-family: Arial, Helvetica, sans-serif"    >      Autenticación en la curia Diocesana de Fontibón, Carrera 98 # 17 A - 81      Fontibón - Centro. <br />      Tel 4181036, Horario de atención, Lunes a Viernes de 9:00 a 1:00 P.M      (Validez a 3 Meses)    </div>'
-- select * 
from Dim_Documentos a
where Id_Documento = 1