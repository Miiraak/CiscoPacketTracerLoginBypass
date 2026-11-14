# Cisco Packet Tracer - LoginBypass
## Description
A simple batch file for bypassing the login prompt of Cisco Packet Tracer.

I've used a stupid method that consist to add an outbound firewall rule to block the Cisco Packet Tracer internet communication... <br>
Packed in a little batch file for easy uses. 

## Features
- **Login Bypass :** Bypass the login prompt.
- **On/Off :** Simply enable and disable the Bypass.
- **Admin-Request :** Auto-Elevated demand if not launch as adminsitrator.
- **Automatic check :** Automatically find Cisco Packet Tracer installation path.
- **Support multi version :** Work on different version of Cisco Packet Tracer _(Tested on v8.2.2, v9.0.0)_.
- **Localized strings :** Automatic Windows language detection (English/Italian/French)
- **OS Detection :** Automatic Operating System check (Windows 10 or 11)

## Prerequisites
- [Windows 10/11](https://www.microsoft.com/windows/)
- **Any Cisco Packet Tracer :** [Official](https://www.netacad.com/packet-tracer-download) / [Archives](https://www.computernetworkingnotes.com/ccna-study-guide/download-packet-tracer-for-windows-and-linux.html)
- Windows Firewall : Enabled

The file automatically checks for Windows 10 or 11 and if Cisco Packet Tracer is installed. If it does not find Cisco Packet Tracer or find a older version of Windows, it will not allow the bypass process to continue.

## Usage
- Launch the .bat.
- Follow the prompt, 0 to exit, 1 to enable, 2 to disable.
- Start Cisco Packet Tracer.
- Enjoy no login.

## Contributing
- [**Tecnologica-Mente**](https://github.com/Tecnologica-Mente) - *Fork Developer*

Contributions are welcome! To contribute to this project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature (`git checkout -b my-new-feature`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add my new feature'`).
5. Push your branch (`git push origin my-new-feature`).
6. Open a Pull Request.

## Issues and Suggestions
If you encounter any issues or have suggestions for improving the project, please use the [GitHub issue tracker](https://github.com/Miiraak/PTLoginBypass/issues).

## License
This project is licensed under the MIT. See the [LICENSE](./LICENSE) file for more details.

## Authors
- [**Miiraak**](https://github.com/Miiraak) - *Lead Developer*
