# 这是一个 overlay，用于将 infuse 添加到 pkgs 中
final: prev: { inherit ((import prev.inputs.infuse { inherit (final) lib; }).v1) infuse; }
