# XPrinter CUPS драйвер для NixOS

Этот репозиторий содержит Nix-пакет для драйверов принтеров XPrinter. Пакет основан на официальном .deb пакете `printer-driver-xprinter` версии 3.13.14.

## Установка

### Через Flakes (рекомендуется)

Добавьте этот репозиторий как входные данные в вашем `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    xprinter-cups.url = "github:fnltochka/xprinter-cups-nix";
  };

  outputs = { self, nixpkgs, xprinter-cups, ... }:
    {
      nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          xprinter-cups.nixosModules.default
          {
            services.printing.drivers.xprinter.enable = true;
          }
        ];
      };
    };
}
```

### Через импорт пакета

Если вы не используете flakes, вы можете установить пакет, добавив его в свою конфигурацию NixOS:

```nix
{ config, pkgs, ... }:

let
  xprinter-driver = pkgs.callPackage /path/to/xprinter-cups-nix {};
in
{
  services.printing.enable = true;
  services.printing.drivers = [ xprinter-driver ];
}
```

## Поддерживаемые архитектуры

Пакет поддерживает следующие архитектуры:
- x86_64 (x64)
- i686 (x86)
- aarch64 (ARM64)
- armv7l (ARM 32-bit)

## Настройка CUPS

После установки драйвера вам необходимо:

1. Убедиться, что служба CUPS запущена: `sudo systemctl restart cups`
2. Открыть веб-интерфейс CUPS: `http://localhost:631`
3. Добавить принтер через интерфейс CUPS
4. При выборе драйвера найдите соответствующую модель в списке XPrinter

## Решение проблем

Если у вас возникают проблемы с драйвером:

1. Проверьте журналы CUPS: `journalctl -u cups`
2. Убедитесь, что ваша модель принтера находится в списке поддерживаемых (PPD-файлы)
3. Убедитесь, что вы выбрали правильный драйвер для своей модели принтера
4. Если возникает ошибка сборки связанная с правами доступа:
   - Убедитесь, что используете последнюю версию пакета
   - Попробуйте собрать пакет в чистом окружении: `nix-build --option sandbox true`
   - При использовании flakes, добавьте опцию `nix build --option sandbox true`

## Лицензия

Этот пакет распространяется под той же лицензией, что и оригинальный драйвер XPrinter. 