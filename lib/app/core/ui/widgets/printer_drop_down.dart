import 'package:flutter/material.dart';
import 'package:gestor_paipfood/app/controller/printer_controller.dart';
import 'package:gestor_paipfood/app/models/printer_model.dart';
import 'package:gestor_paipfood/app/repositories/printer_repository.dart';

class PrinterDropDown extends StatefulWidget {
  const PrinterDropDown({
    Key? key,
  }) : super(key: key);

  @override
  State<PrinterDropDown> createState() => _PrinterDropDownState();
}

class _PrinterDropDownState extends State<PrinterDropDown> {
  late final PrinterRepository printerRepository =
      PrinterRepositorySharedPreferences();
  late final controller = PrinterController(printerRepository);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return DropdownButtonFormField(
              decoration: InputDecoration(
                prefixIcon: !controller.hasSelectedPrinter
                    ? const Icon(Icons.print_outlined)
                    : null,
                label: Text(!controller.hasSelectedPrinter
                    ? "Selecione uma impressora"
                    : "Impressora"),
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              value: controller.selectedPrinter,
              items: controller.printers.map((PrinterModel printer) {
                return DropdownMenuItem(
                  value: printer,
                  child: Row(children: [
                    const Icon(Icons.print_outlined),
                    const SizedBox(width: 5),
                    Text(printer.deviceName.toString()),
                  ]),
                );
              }).toList(),
              onChanged: controller.setSelectedPrinter);
        });
  }
}
