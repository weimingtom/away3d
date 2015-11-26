Plese read SubclipseInstructions if you haven't installed the subclipse plugin in Flexbuilder

  * Open the svn repository explorer by selecting _Window > Open Perspective > Other..._ and from the file menu and clicking on **SVN Repository Exploring**.

  * Right-click anywhere in the **SVN Repository** window on the left, and select _New > Repository Location..._ from the menu.

  * Enter the url given in the svn link of the example you wish to download. In the case of the EngineTest example, this is http://away3d.googlecode.com/svn/trunk/examples/EngineTest/. Click on finish. If the url is correct, the new repository location should appear in your **SVN Repository** window.

  * Right click on the new repository location, and select _Checkout..._ from the menu. This will open the **Checkout from SVN** popup.

  * Ensure the _Check out as a project configured using the New Project Wizard_ option is selected, and click on the Finish button.

  * Locate the **Flex Project** wizard from the list, and click Next.

  * Ensure the _Basic_ option is selected, and click Next.

  * Name the project the same name as the example you are checking out from SVN. So for the EngineTest example, type EngineTest in the _Project name_ input field, and click Next.

  * In the _Main source folder_ input field type src and click on the Finish button.

  * A prompt will ask you whether you want to switch to the Flex Development Perspective. Click ok.

  * A prompt will ask you to confirm the overwrite of any resources in the created project other than the standard .project file. Since this is a new project the folder will be empty, so click on ok.

  * Once the folder has completed checking out, you can browse to it by locating the project directory in the **Navigator** window.

  * locate the main project class by browsing inside the src folder of the project. It should be named the same as the example name, so for the EngineTest example, look for for the EngineTest.as file.

  * Right click on the file and select _Run As > Flex Application_ from the menu.

  * The project should compile and Flexbuilder will automatically open a browser window to display the example. You may get a prompt if you haven't got the flash 9 debug player installed on the default browser, but this is not required to view the compiled example.