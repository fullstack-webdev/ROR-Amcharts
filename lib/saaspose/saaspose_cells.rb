require_relative 'saaspose_storage'

# This module provide wrapper classes to work with Saaspose.Cells resources
module Cells
    # This class provides functionality for converting Excel Spreadsheets to other supported formats.
    class Convertor
        # Constructor for the Convertor Class.
        # * :name represents the name of the Excel Spreadsheet on the Saaspose server 		
        def initialize(name)  
             # Instance variables   
             @name = name
        end
	     # Converts the file available at Saaspose Storage and saves converted file locally.
		 # * :localFile represents converted local file path and name
         # * :saveFormat represents the converted format. For a list of supported formats, please visit 
		 #  http://saaspose.com/docs/display/cells/workbook		 
        def convert(localFile,saveFormat)
		    urlDoc = $productURI + '/cells/' + @name + '?format=' + saveFormat
		    signedURL = Common::Utils.sign(urlDoc)
		    response = RestClient.get(signedURL, :accept => 'application/json')
			Common::Utils.saveFile(response,localFile)
        end		
    end  
end
