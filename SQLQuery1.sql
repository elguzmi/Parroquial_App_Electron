drop table Dim_Variables_Globales
CREATE TABLE Dim_Variables_Globales(
	Id_Variable int identity(1,1),
	Nombre varchar(50),
	Valor varchar(500),
	Is_Active bit default 1,
	Created_By VARCHAR(20) default suser_sname(),
	Created_On datetime default getdate()
)

INSERT INTO Dim_Variables_Globales(Nombre,Valor)
values
('NombreLocal', 'DIÓCESIS DE FONTIBÓN')
,('Parroquia', 'PARROQUIA JESÚS EUCARISTÍA')
,('Dirreccion', 'Diagonal 16 # 104 - 51 local 117')
,('Cel', '322-7447219')
,('Correo', 'despachojesuseucaristia@gmail.com')
,('Ciudad', 'Bogotá - Cundinamarca')


drop table Dim_Documentos
CREATE TABLE Dim_Documentos(
	Id_Documento int identity(1,1),
	Nombre varchar(50),
	Html_Header varchar(max),
	Html_Body varchar(max),
	Html_Footer varchar(max),
	Parametros varchar(300),
	Tabla varchar(50),
	Is_Active bit default 1,
	Created_By VARCHAR(20) default suser_sname(),
	Created_On datetime default getdate()
)

insert into Dim_Documentos(
	Nombre,Html_Header, Html_Body,Html_Footer,Parametros,Tabla
)values(
	'Acta de Bautismo',
	'<div style="width: 100%; text-align: center;line-height: 8px;">
      <p style="font-size: 24px;font-weight: 700;">@NombreLocal</p>
      <p style="font-weight: 700;">@Parroquia</p>
      <p> @Direccion Cel.@Cel</p>
      <p>Correo: @Correo</p>
      <p> @Ciudad </p>
    </div>',
	'<div class="body" style="text-align: center;">
      <p style="font-size: 25px;font-weight: 700;">ACTA DE BAUTISMO</p>
      <p style="font-size: 20px;font-weight: 700;">@Nombre</p>
      <div>
        <span>Libro : @Libro </span>
        <span>Folio : @Folio </span>
        <span>Numero : @Numero </span>
      </div>

      <div style="width: 70%; margin: 0 auto">
        <table border="1" style="border-collapse: collapse; width: 100%">
          <tr>
            <td>En la parroquia</td>
            <td>:</td>
            <td colspan="2">JESÚS EUCARISTÍA</td>
          </tr>
          <tr>
            <td>Fecha de bautismo</td>
            <td>:</td>
            <td colspan="2">@Fecha_Bautismo</td>
          </tr>
          <tr>
            <td>Ministro</td>
            <td>:</td>
            <td colspan="2">@Ministro</td>
          </tr>
          <tr>
            <td>Nombres y apellidos</td>
            <td>:</td>
            <td colspan="2">@Nombre</td>
          </tr>
          <tr>
            <td>Lugar de nacimiento</td>
            <td>:</td>
            <td colspan="2">@Lugar_Nacimiento</td>
          </tr>
          <tr>
            <td>Fecha de nacimiento</td>
            <td>:</td>
            <td colspan="2">@Fecha_Nacimiento</td>
          </tr>
          <tr>
            <td>Hijo(a) de</td>
            <td>:</td>
            <td colspan="2">@Padres</td>
          </tr>
          <tr>
            <td>Abuelos paternos</td>
            <td>:</td>
            <td colspan="2">@Abuelos_Paternos</td>
          </tr>
          <tr>
            <td>Abuelos Maternos</td>
            <td>:</td>
            <td colspan="2">@Abuelos_Maternos</td>
          </tr>
          <tr>
            <td>Padrinos</td>
            <td>:</td>
            <td colspan="2">@Padrinos</td>
          </tr>
          <tr>
            <td>Doy Fe</td>
            <td>:</td>
            <td colspan="2">@DoyFe</td>
          </tr>
          <tr>
            <td>Notas Marginales</td>
            <td>:</td>
            <td colspan="2">@Nota_Marginal</td>
          </tr>
          <tr>
            <td colspan="4" style="text-align: left">
              Expedida en : Bogota, Cundinamarca el 12 de junio de 2023
            </td>
          </tr>
        </table>
        <div style="width: 100%; text-align: right;margin-top: 30px;">
			<div>
			  <span>___________________________</span><br />
			  @Firmante <br />
			  @Cargo
			</div>
        </div>
      </div>
    </div>',
	'
	<div class="footer" style="text-align:center">
		Autenticación en la curia Diocesana de Fontibón, Carrera 98 # 17 A - 81 Fontibón - Centro. <br>
		Tel 4181036, Horario de atención, Lunes a Viernes de 9:00 a 1:00 P.M (Validez a 3 Meses)
	</div>'
	,
	'@Libro|@Folio|@Numero|@Fecha_Bautismo|@Ministro|@Nombre|@Lugar_Nacimiento|@Fecha_Nacimiento|@Padres|@Abuelos_Paternos|@Abuelos_Maternos|@Padrinos|@DoyFe|@Nota_Marginal|@Firmante|@Cargo',
	'Fact_Bautismos'
)