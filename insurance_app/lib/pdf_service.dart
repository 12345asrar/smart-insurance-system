import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> printMarriageGrantDocument({
    required String applicantName,
    required String kinship,
    required double grantAmount,
    required String date,
    required String refNo,
  }) async {
    final pdf = pw.Document();

    // تحميل خط يدعم اللغة العربية تلقائياً
    final font = await PdfGoogleFonts.cairoMedium();
    final boldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.teal800, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // الترويسة الرسمية
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'الجمهورية اليمنية',
                          style: pw.TextStyle(font: boldFont, fontSize: 13),
                        ),
                        pw.Text(
                          'المؤسسة العامة للتأمينات الاجتماعية',
                          style: pw.TextStyle(font: boldFont, fontSize: 13),
                        ),
                        pw.Text(
                          'إدارة المنافع والتعويضات التأمينية',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'رقم القرار: $refNo',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          'التاريخ: $date',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.teal800),
                pw.SizedBox(height: 18),

                // عنوان السند
                pw.Center(
                  child: pw.Text(
                    'قرار اعتماد وصرف منحة زواج بنات',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 18,
                      color: PdfColors.teal900,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // نص القرار والمطابقة القانونية
                pw.Text(
                  'استناداً إلى أحكام قانون التأمينات الاجتماعية ولائحته التنفيذية، وبعد مراجعة عقد القران الشرعي والتحقق من واقعة الزواج والأنصبة المستحقة من معاش المتوفى، تقرر صرف الإعانة المالية المقررة قانوناً (معاش 12 شهراً مقطوعة لمرة واحدة):',
                  style: const pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.justify,
                ),
                pw.SizedBox(height: 20),

                // جدول البيانات المالية
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'البيان',
                            style: pw.TextStyle(font: boldFont, fontSize: 12),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'التفاصيل والمعطيات',
                            style: pw.TextStyle(font: boldFont, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('اسم المستفيدة (العروس)'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(applicantName),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('صفة القرابة بالمتوفى'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(kinship),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('نوع المعاملة التأمينية'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('منحة زواج إناث (12 شهراً)'),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'إجمالي المبلغ المعتمد للصرف',
                            style: pw.TextStyle(font: boldFont),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${grantAmount.toStringAsFixed(2)} ريال يمني',
                            style: pw.TextStyle(
                              font: boldFont,
                              color: PdfColors.teal900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  '* ملاحظة إدارية: يتم تسوية نصيب المذكورة أعلاه بإيقاف صرف المعاش الشهري اعتباراً من تاريخ عقد القران وإعادة توزيعه على بقية الورثة وفق النسب الشرعية والتأمينية.',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Spacer(),

                // التوقيعات والختم
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(
                          'مدقق إدارة المنافع',
                          style: pw.TextStyle(font: boldFont, fontSize: 11),
                        ),
                        pw.SizedBox(height: 25),
                        pw.Text('.......................'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'مدير الشؤون المالية',
                          style: pw.TextStyle(font: boldFont, fontSize: 11),
                        ),
                        pw.SizedBox(height: 25),
                        pw.Text('.......................'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'ختم الفرع الرسمي',
                          style: pw.TextStyle(font: boldFont, fontSize: 11),
                        ),
                        pw.SizedBox(height: 25),
                        pw.Text(
                          '[ خــتــم الاعـتـمـاد ]',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );

    // فتح شاشة المعاينة والطباعة أو المشاركة كملف PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'قرار_منحة_زواج_$applicantName.pdf',
    );
  }
}
