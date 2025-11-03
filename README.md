The goal of the project is to create helper that allows to run QGC that will be configured for specifyc device and quiqly switch between configs/devices when it's necessary.

How to use: run QGC_Config_Generator.bat, fill what it asks and it will generate an INI config and batch file to run QGC with this config.
The newly generated batch file deletes current QGC config and creates a symlink that points to newly created one. To do this it needs to be runed with admin rights. 
