# Creating custom tiles for the Windows 8/10 start menu is a way bigger pain than it should be.
### My aim is to fix that.

Instructions: 
1. Download/clone from https://github.com/Aarilight/custom-tiles
1. Run create-tile.bat
1. Input `y`, for yes, to add a context menu on the Supported FileTypes.
1. Right click on a file of one of the supported file types*, and run the new context menu command Create Custom Tile.
1. A new console window should open, reopening if it requires administrator permissions to add a tile for this file (common for Program Files apps)
1. When the tile can be created, you will have a prompt for an image. This will be the logo on your tile.
1. Type in the path of your image (or drag it to the console).
1. Type in whether your text should be white or black (light/dark).
1. Type in the hex colour of the background of your tile.
1. Pin the .exe to Start.
1. Profit.

*Note: For `lnk`, `appref-ms`, and `bat` files, custom-tiles will automatically download a utility called [ps2exe](https://gallery.technet.microsoft.com/PS2EXE-Convert-PowerShell-9e4e07f1). After it downloads and extracts, it may be blocked by default, therefore preventing it from working. Go to `/dependencies`, then right click on `ps2exe.ps1`. At the bottom you may see an empty checkbox. Check it. ![unblock me](./preview/unblock.png)

## Not convinced?

![Example](./preview/preview.png)


### Supported FileTypes
`exe`
`lnk`
`appref-ms`
`bat`

Open an issue if you need another filetype supported.

### Dependencies

This project would not work on non-exe files if not for [ps2exe](https://gallery.technet.microsoft.com/PS2EXE-Convert-PowerShell-9e4e07f1). (Or at least, it would have taken me a lot longer to implement)
