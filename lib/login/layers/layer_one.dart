import "package:flutter/material.dart";
import "package:patinka/login/config.dart";

class LayerOne extends StatelessWidget {
  const LayerOne({super.key});

  @override
  Widget build(final BuildContext context) => Container(
      width: MediaQuery.of(context).size.width,
      height: 654,
      decoration: BoxDecoration(
        color: layerOneBg,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(60.0), bottomRight: Radius.circular(60.0)),
      ),
    );
}
