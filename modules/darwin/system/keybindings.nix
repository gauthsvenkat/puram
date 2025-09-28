{ config, ... }:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username}.targets.darwin.keybindings = {
    "^c" = "copy:";
    "^v" = "paste:";
    "^x" = "cut:";

    "^z" = "undo:";
    "^y" = "redo:";

    "^a" = "selectAll:";

    "\\UF729" = "moveToBeginningOfLine:"; # Home
    "\\UF72B" = "moveToEndOfLine:"; # End
    "$\\UF729" = "moveToBeginningOfLineAndModifySelection:"; # Shift + Home
    "$\\UF72B" = "moveToEndOfLineAndModifySelection:"; # Shift + End

    "^\\UF729" = "moveToBeginningOfDocument:"; # Ctrl + Home
    "^\\UF72B" = "moveToEndOfDocument:"; # Ctrl + End
    "$^\\UF729" = "moveToBeginningOfDocumentAndModifySelection:"; # Shift + Ctrl + Home
    "$^\\UF72B" = "moveToEndOfDocumentAndModifySelection:"; # Shift + Ctrl + End

    "^\\UF702" = "moveWordLeft:"; # Ctrl + Left Arrow
    "^\\UF703" = "moveWordRight:"; # Ctrl + Right Arrow
    "$^\\UF702" = "moveWordLeftAndModifySelection:"; # Shift + Ctrl + Left Arrow
    "$^\\UF703" = "moveWordRightAndModifySelection:"; # Shift + Ctrl + Right Arrow

    "^\\U007F" = "deleteWordBackward:"; # Ctrl + Backspace
    "^\\UF728" = "deleteWordForward:"; # Ctrl + Delete

    # Arrow keys with Shift for selection
    "$\\UF700" = "moveUpAndModifySelection:"; # Shift + Up Arrow
    "$\\UF701" = "moveDownAndModifySelection:"; # Shift + Down Arrow
    "$\\UF702" = "moveLeftAndModifySelection:"; # Shift + Left Arrow
    "$\\UF703" = "moveRightAndModifySelection:"; # Shift + Right Arrow
  };
}
