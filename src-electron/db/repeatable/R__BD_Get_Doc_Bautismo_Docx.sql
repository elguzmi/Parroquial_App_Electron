/*
  Product SP: BD_Get_Doc_Bautismo_Docx
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Doc_Bautismo_Docx]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cesar Santiago Guzman - Ing Desarrollo
-- Create date: 26/04/2023
-- Description:	Procedimiento que permite conseguir el HTML del documento
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Doc_Bautismo_Docx]
@tipo varchar(10) = 'Header'
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		
		if @tipo = 'Header'  begin

			select 
				'<div class="header" style="font-family: Arial, Helvetica, sans-serif;font-size: 18px;margin-top:3px;width:800px;text-align:center">
					<div style="width: 100%; text-align: center;line-height: 0px;" class="title">
						<span style="font-size: 24px;font-weight: 700;width:100% ;text-align: center;">
							<b>DIÓCESIS DE FONTIBÓN</b>
						</span>
						<span style="font-weight: 700;width:100% ; text-align: center;">
							<b>PARROQUIA JESÚS EUCARISTÍA</b>
						</span>
						<span style="width:100%; text-align: center;"> 
							Diagonal 16 # 104 - 51 local 117 Cel.322-7447219
						</span>
						<span style="width:100% ; text-align: center;">
							Correo: despachojesuseucaristia@gmail.com</span>
						<span style="width:100% ;text-align: center;"> 
							Bogotá - Cundinamarca 
						</span>   
					</div>   
				</div>'
			return
		end


		else if @tipo = 'Body'  begin

			select 
				'<table align="left" border="0" class="Table" cellspacing="3" cellpadding="0" style="border-spacing: 1px; width: 100%;margin: 0px;border: none;   border-collapse:collapse      line-height:1pt;   padding:0px 0px 0px 0px;    ">
					<tbody style="border: none">
						<tr>
							<td colspan="30" style="width: 650px; text-align: center; border-left: none" valign="top"> 
								<span style="font-size: 14pt">
									<span style="line-height:-1pt">
										<b>ACTA DE BAUTISMO</b>
									</span>
								</span>
								<span style="font-size: 14pt">
									<span style="line-height:-1pt">
										<b>@Nombre</b>
									</span>
								</span>
								<p style="margin-bottom: 0px">
								<span style="font-family: Arial, Helvetica, sans-serif">
									<span style="font-size: 10pt">
										<span style="line-height: 0pt">
											Libro : @Libro &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Folio : @Folio &nbsp;&nbsp;Número : @Numero
										</span>
									</span>
								</span>
								</p>
							</td>      
						</tr>
						<tr style="height: 1pt; line-height: 6pt; margin:2px 0 2px 0; padding:2px 0 2px 0">
							<td colspan="3" style="width: 150px" valign="top; margin:2px 0 2px 0; padding:2px 0 2px 0;">
								<span style="text-align: left; line-height: 6pt; font-size: 10pt; margin:2px 0 2px 0; padding:2px 0 2px 0">
									En la parroquia
								</span>
							</td>
							<td valign="top; padding:0px 0px 0px 0px;">
								<span style="text-align: left;  line-height: 6pt; font-size: 10pt;  margin:2px 0 2px 0; padding:2px 0 2px 0">
									:
								</span> 
							</td>
							<td colspan="26" style="width: 425px;text-align: left;margin:2px 0 2px 0; padding:2px 0 2px 0 ;border-left: 0px;line-height: 6pt;" valign="top">
								<span style="text-align: left; display: block; line-height: 6pt; font-size: 10pt">
									JESÚS EUCARISTÍA
								</span>
							</td>
						</tr>
						<tr style="height: 3px; line-height: 0px; padding: 0px; margin-bottom: 1px">
							<td colspan="3" style="width: 150px" valign="top">
								<span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">
									Fecha de bautismo
								</span> 
							</td>
							<td colspan="1" style="width: 2px; padding: 0px" valign="top">
								<span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">
									:
								</span>
							</td>
							<td colspan="26" style="width: 425px;text-align: left;padding: 0px 0px 0px 0px;line-height: 0;text-indent: 1cm;margin: 0 auto;" valign="center">
								<span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">
									@Fecha_Bautismo
								</span>
							</td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="3" style="width: 150px" valign="top">
								<span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">
									Ministro
								</span>
							</td>
							<td valign="top">
								<span style="text-align: left; display: inline; line-height: 12pt;font-size: 10pt">
									:
								</span>
							</td>
							<td colspan="26" style="width: 425px; text-align: left; padding: 0px 0px 0px 0px" valign="top">
								<span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">
									@Ministro
								</span>
							</td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="3" style="width: 150px" valign="top">
								<span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">
									Nombres y apellidos
								</span>
							</td>
							<td colspan="1" style="width: 2px" valign="top">
								<span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">
									:
								</span>
							</td>
							<td colspan="26" style="width: 425px; text-align: left; padding: 0px 0px 0px 0px" valign="top">
								<span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">
									@Nombre
								</span>
							</td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="3" style="width: 150px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">Lugar de nacimiento</span> </td>
							<td colspan="1" style="width: 2px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">:</span> </td>
							<td colspan="26" style="width: 425px; text-align: left; padding: 0px 0px 0px 0px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">@Lugar_Nacimiento</span> </td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="3" style="width: 150px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">Fecha de nacimiento</span> </td>
							<td colspan="1" style="width: 2px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">:</span> </td>
							<td colspan="26" style="width: 425px; text-align: left; padding: 0px 0px 0px 0px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">@Fecha_Nacimiento</span> </td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="3" style="width: 150px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">Hijo(a) de</span> </td>
							<td valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">:</span> </td>
							<td colspan="26" style="width: 425px; text-align: left; padding: 0px 0px 0px 0px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">@Padres</span> </td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="3" style="width: 150px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">Abuelos paternos</span> </td>
							<td colspan="1" style="width: 2px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">:</span> </td>
							<td colspan="26" style="width: 425px; text-align: left; padding: 0px 0px 0px 0px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">@Abuelos_Paternos</span> </td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="3" style="width: 150px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">Abuelos maternos</span> </td>
							<td colspan="1" style="width: 2px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">:</span> </td>
							<td colspan="26" style="width: 425px; text-align: left; padding: 0px 0px 0px 0px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">@Abuelos_Maternos</span> </td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="3" style="width: 150px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">Padrinos</span> </td>
							<td colspan="1" style="width: 2px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">:</span> </td>
							<td colspan="26" style="width: 425px; text-align: left; padding: 0px 0px 0px 0px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">@Padrinos</span> </td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="3" style="width: 150px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">Doy Fe</span> </td>
							<td colspan="1" style="width: 2px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">:</span> </td>
							<td colspan="26" style="width: 425px; text-align: left; padding: 0px 0px 0px 0px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">@DoyFe</span> </td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="3" style="width: 150px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">Notas Marginales</span> </td>
							<td colspan="1" style="width: 2px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt">:</span> </td>
							<td colspan="26" style="width: 425px; text-align: left; padding: 0px 0px 0px 0px" valign="top"> <span style="text-align: left; display: inline; line-height: 12pt; font-size: 10pt; margin-bottom:10px;">@Nota_Marginal</span> </td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="30" style="width: 650px; text-align: left; " valign="center"> </td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="30" style="width: 650px; text-align: left; " valign="center"> <span style="font-family: Arial, Helvetica, sans-serif">
							<span style="font-size: 10pt">
								<span style="line-height: 0.5pt" >
									<span style="color: black">
										@ExpedidoEn
									</span>
								</span>
							</span>
							</td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="30" style="width: 650px; text-align: left; " valign="center"> </td>
						</tr>
						<tr style="height: 5px; line-height: 0px; margin: 0px; padding: 0px">
							<td colspan="9" style="width: 180px" valign="top"> </td>
							<td colspan="1" style="width: 2px" valign="top"> </td>
							<td colspan="20" style="width: 410px; text-align: center; padding: 0px 0px 0px 0px" valign="top">
								<p style="font-size: 10pt margin-bottom:10px;"> @Linea</p>
								<p></p>
								<p style="font-size: 10pt;"> @Firmante </p>
								<p style="font-size: 10pt;"> @cargo </p>
							</td>
						</tr>
					</tbody>
				</table>'
			return
		end

		select Html_Body_Docx_Node from Dim_Documentos
		where Id_Documento = 1
		

	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
