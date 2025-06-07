/** $module_id ($azmunaas_toolbox) is a sanitized version of the module ID. It is used to create unique variable names in JavaScript. The sanitized version replaces any non-alphanumeric characters with underscores and prefixes the ID with a dollar sign.
* window.$azmunaas_toolbox - ModuleInterface
* window.$AzFile - FileManager
* window.$AzFileInputStream - FileInputInterface
*/
declare var $module_id: ModuleInterface; // accesspoint for webui-x

interface ModuleInterface {
  getWindowTopInset(): number;
  getWindowBottomInset(): number;
  getWindowLeftInset(): number;
  getWindowRightInset(): number;
  isLightNavigationBars(): boolean;
  isDarkMode(): boolean;
  setLightNavigationBars(isLight: boolean): void;
  isLightStatusBars(): boolean;
  setLightStatusBars(isLight: boolean): void;
  getSdk(): number;
  shareText(text: string): void;
  /* overload */ shareText(text: string, type: string): void;
  getRecomposeCount(): number;
  /**
   * Reloads the entire WebUI
   */
  recompose(): void;
  createShortcut(): void;
  /* overload */ createShortcut(title: string | null, icon: string | null): void;
  hasShortcut(): boolean;
}
