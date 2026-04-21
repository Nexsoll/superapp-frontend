import 'package:get/get.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ReceiptService {
  static Future<File> generateReceipt({
    required String bookingReference,
    required String bookingType,
    required String listingTitle,
    required String location,
    required String checkIn,
    required String checkOut,
    required int guests,
    required String totalPaid,
    required String email,
    required String paymentMethod,
    String? roomType1,
    String? roomType2,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#2FC1BE'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('BOOKING RECEIPT'.tr,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Super App'.tr,
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Booking Reference
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('#2FC1BE'), width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Booking Reference:'.tr,
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      bookingReference,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#2FC1BE'),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Booking Details
              pw.Text('Booking Details'.tr,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),

              _buildDetailRow('Property:', listingTitle),
              _buildDetailRow('Location:', location),
              _buildDetailRow('Type:', bookingType == 'hotel' ? 'Hotel Booking' : 'Property Purchase'),
              if (roomType1 != null && roomType1.isNotEmpty)
                _buildDetailRow('Room Type:', roomType1),
              if (roomType2 != null && roomType2.isNotEmpty)
                _buildDetailRow('Additional Room:', roomType2),
              pw.SizedBox(height: 10),

              // Dates
              pw.Text('Stay Details'.tr,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),

              _buildDetailRow('Check-in:', checkIn),
              _buildDetailRow('Check-out:', checkOut),
              _buildDetailRow('Guests:', guests.toString()),
              pw.SizedBox(height: 10),

              // Payment Details
              pw.Text('Payment Details'.tr,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),

              _buildDetailRow('Payment Method:', paymentMethod),
              _buildDetailRow('Email:', email),
              pw.SizedBox(height: 20),

              // Total
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E8F8F7'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Paid:'.tr,
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      totalPaid,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#2FC1BE'),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),
              pw.Text('Thank you for booking with Super App!'.tr,
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
              pw.Text(
                'Generated on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/receipt_$bookingReference.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
