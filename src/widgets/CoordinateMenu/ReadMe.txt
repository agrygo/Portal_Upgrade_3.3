     #
	 # Coordinate Menu Widget Read Me
	 #
	 ############################################################################
     ## Created By: Andrew Timmins
     ## Date: Feb 6, 2012
     ## Location: Ontario Canada
     ## For: Flex-A-Widget Challenge
     ## ------------------------------------------------------------------------
     ## References:
     ## ESRI: Flex API, Flex Viewer - Source
     ## Images courtesy of FAMFAMFAM - Silk Icon Set - http://www.famfamfam.com/lab/icons/silk/
     ############################################################################
	 
	 How to add to config.xml
	 --------------------------------------------------
	
	********************************************************************************* 
	*ADD TO CONTEXT MENU
	*********************************************************************************
	 Under the UI Elements section of the config.xml file add the following line:
	  
     <widget left="0"  top="0"  config="widgets/CoordinateMenu/CoordinateMenuWidget.xml" url="widgets/CoordinateMenu/CoordinateMenuWidget.swf"/>
	 
	*********************************************************************************
	* ADD AS A STANDARD WIDGET WITH A GRAPHICAL INTERFACE (GUI)
	*********************************************************************************
	 Inside the widget container add the following lines of code
	 <widget label="Map Coordinates"
     		preload="open"
            config="widgets/CoordinateMenu/CoordinateMenuWidget.xml"
            icon="widgets/CoordinateMenu/images/coordinateIcon.png"
            left="100" top="80"
            url="widgets/CoordinateMenu/CoordinateMenuWidget_GUI.swf"/>
    
	 
	 
	 
	 Open the CoordinateMenuWidget.xml file amd set your desired properties.
	 If you do not wish to have the projection option remove all the <coordinateSystem/> tags. 
	 
	 Rebuild you application and clear your browsers cache if you feel necessary.
	 
	 Right click on your map and test the new widget.
	 
	 Enjoy!
	 
	 Please report any comments or bugs on the widget page.
	 
	 Andrew Timmins