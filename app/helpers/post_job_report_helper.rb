module PostJobReportHelper

    include JobLogHelper
    include JobsHelper

    def upload

        Common::Product.setBaseProductUri("http://api.saaspose.com/v1.0")
        Common::SaasposeApp.new(ENV["SAASPOSE_APPSID"], ENV["SAASPOSE_APPKEY"])

        #strURI = 'http://api.saaspose.com/v1.0/storage/file/elephant-docs/docs/b490e1def086c4592431453a7f12d977/56 - Custom Document - 144.pdf?storage=elephant'
        #signedURI = Common::Utils.sign(strURI)
        #Common::Utils.uploadFileBinary('C:/input1.pdf',signedURI)


        oldFile = 'http://api.saaspose.com/v1.0/pdf/new.pdf?format=pdf&storage=elephant&folder=elephant-docs'

        #oldFile = 'http://api.saaspose.com/v1.0/words/BHQA_RD_01.docx?format=pdf&storage=elephant&folder=elephant-docs'
        newFile = 'http://api.saaspose.com/v1.0/storage/file/elephant-docs/new.pdf?storage=elephant'
        #responseStream = RestClient.get Common::Utils.sign(oldFile), { :accept => :json }
        RestClient.put Common::Utils.sign(newFile), open(Common::Utils.sign(oldFile)), {:accept => :json}


        #strURI = 'http://api.saaspose.com/v1.0/pdf/56 - Custom Document - 144.pdf?format=doc&storage=elephant&folder=elephant-docs/docs/b490e1def086c4592431453a7f12d977'
        #signedURI = Common::Utils.sign(strURI)
        #puts RestClient.put signedURI, 'sfd.pdf', {:accept => :json }

        #strURI = 'http://api.saaspose.com/v1.0/pdf/MergedFile3.pdf/merge?storage=elephant&folder=elephant-docs'
        #signedURI = Common::Utils.sign(strURI)

        #json = JSON.generate("List"=>['elephant-docs/MergedFile.pdf', 'elephant-docs/MergedFile.pdf'])
        #RestClient.put signedURI, json, {:content_type => :json}

    end

end

def convert(document)
    if !document.nil?
        Common::Product.setBaseProductUri("http://api.saaspose.com/v1.0")
        Common::SaasposeApp.new(ENV["SAASPOSE_APPSID"], ENV["SAASPOSE_APPKEY"])

        oldFile = ""

        begin

            if document.document_type == Document::JOB_LOG
                document.url = "#{document.company_id}/#{SecureRandom.hex}/#{document.name}.xlsx"
                excel = logs_to_excel(JobLog.where(:document_id => document.id).order("entry_at ASC"), document)
                s3 = AWS::S3.new
                s3.buckets['elephant-docs'].objects[document.url].write(excel.to_stream)
                document.save
            elsif document.document_type == Document::CUSTOM_DATA
                document.url = "#{document.company_id}/#{SecureRandom.hex}/#{document.name}.xlsx"
                excel = custom_data_to_excel(document.job)
                s3 = AWS::S3.new
                s3.buckets['elephant-docs'].objects[document.url].write(excel.to_stream)
                document.save
            end


            case File.extname(document.url).downcase
                when ".xls", ".xlsx", ".xlsm", ".xltx", ".xltm", ".xlsb", ".xlam", ".xll"
                    oldFile = "http://api.saaspose.com/v1.0/cells/#{File.basename(document.url)}?format=pdf&storage=elephant&folder=elephant-docs/#{File.dirname(document.url)}"
                when ".doc", ".docx", ".rtf", ".txt", ".docm", ".dotx", ".dotm"
                    oldFile = "http://api.saaspose.com/v1.0/words/#{File.basename(document.url)}?format=pdf&storage=elephant&folder=elephant-docs/#{File.dirname(document.url)}"
                when ".pdf"
                    return "elephant-docs/#{File.dirname(document.url)}/#{File.basename(document.url, '.*')}.pdf"
            end

            newFile = "http://api.saaspose.com/v1.0/storage/file/elephant-docs/#{File.dirname(document.url)}/#{File.basename(document.url, '.*')}.pdf?storage=elephant"

            RestClient.put Common::Utils.sign(newFile), open(Common::Utils.sign(oldFile)), {:accept => :json}

            return "elephant-docs/#{File.dirname(document.url)}/#{File.basename(document.url, '.*')}.pdf"
        rescue
            puts "Error #{$!}"
            puts document.url + " " + document.id.to_s
        end
    end

    ""
end

def merge(job, documents)

    Common::Product.setBaseProductUri("http://api.saaspose.com/v1.0")
    Common::SaasposeApp.new(ENV["SAASPOSE_APPSID"], ENV["SAASPOSE_APPKEY"])

    document = job.post_job_report_document
    if !document.nil?
        filename = document.name
        path = "#{document.company_id}/#{SecureRandom.hex}"

        document_names = documents.map { |d| convert(d) }
        document_names = document_names.select { |name| !name.blank? }

        mergedFile = "http://api.saaspose.com/v1.0/pdf/#{filename}/merge?storage=elephant&folder=elephant-docs/#{path}"

        json = JSON.generate("List" => document_names)
        puts json.to_s
        RestClient.put Common::Utils.sign(mergedFile), json, {:content_type => :json}

        document.url = "#{path}/#{filename}"
        document.save
    end

    return document
end


# This module provide common classes and methods to be ued by other SDK modules
module Common

    # This class allows you to set the base host Saaspose URI
    class Product
        # Sets the host product URI.
        def self.setBaseProductUri(productURI)
            $productURI = productURI
        end
    end

    # This class allows you to set the AppSID and AppKey values you get upon signing up
    class SaasposeApp
        def initialize(appSID, appKey)
            $appSID = appSID
            $appKey = appKey
        end
    end

    # This class provides common methods to be repeatedly used by other wrapper classes
    class Utils
        # Signs a URI with your appSID and Key.
        # * :url describes the URL to sign
        def self.sign(url)
            url = URI.escape(url)
            parsedURL = URI.parse(url)

            urlToSign =''
            if parsedURL.query.nil?
                urlToSign = parsedURL.scheme+"://"+ parsedURL.host + parsedURL.path + "?appSID=" + $appSID
            else
                urlToSign = parsedURL.scheme+"://"+ parsedURL.host + parsedURL.path + '?' + parsedURL.query + "&appSID=" + $appSID
            end

            # create a signature using the private key and the URL
            rawSignature = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), $appKey, urlToSign)

            #Convert raw to encoded string
            signature = Base64.strict_encode64(rawSignature).tr('+/', '-_')

            #remove invalid character
            signature = signature.gsub(/[=_-]/, '=' => '', '_' => '%2f', '-' => '%2b')

            #Define expression
            pat = Regexp.new("%[0-9a-f]{2}")

            #Replace the portion matched to the above pattern to upper case
            for i in 0..5
                signature = signature.sub(pat, pat.match(signature).to_s.upcase)
            end

            # prepend the server and append the signature.
            signedUrl = urlToSign + "&signature=#{signature}"
            return signedUrl
        end

        # Parses JSON date value to a valid date format
        # * :datestring holds the JSON Date value
        def self.parse_date(datestring)
            seconds_since_epoch = datestring.scan(/[0-9]+/)[0].to_i
            return Time.at((seconds_since_epoch-(21600000 + 18000000))/1000)
        end

        # Uploads a binary file from the client system
        # * :localfile holds the local file path alongwith name
        # * :url holds the required url to use while uploading the file to Saaspose Storage
        def self.uploadFileBinary(localfile, url)
            RestClient.put(url, File.new(localfile, 'rb'))
        end

        # Gets the count of a particular field in the response
        # * :localfile holds the local file path alongwith name
        # * :url holds the required url to use while uploading the file to Saaspose Storage
        def self.getFieldCount(url, fieldName)
            response = RestClient.get(url, :accept => 'application/xml')
            doc = REXML::Document.new(response.body)
            pages = []
            doc.elements.each(fieldName) do |ele|
                pages << ele.text
            end
            return pages.size
        end

        # Saves the response stream to a local file.
        def self.saveFile(responseStream, localFile)
            open(localFile, "wb") do |file|
                file.write(responseStream.body)
            end
        end
    end
end


# This module provides wrapper classes to work with Saaspose.Storage resources
module Storage
    # This class represents File Saaspose URI data
    class AppFile
        attr_accessor :Name, :IsFolder, :ModifiedDate, :Size
    end

    # This class represents IsExist Saaspose URI data
    class FileExist
        attr_accessor :IsExist, :IsFolder
    end

    # This class represents Disc Saaspose URI data
    class Disc
        attr_accessor :TotalSize, :UsedSize
    end

    # This class provides functionality to manage files in a Remote Saaspose Folder
    class Folder
        # Uploads file from the local path to the remote folder.
        # * :localFilePath represents full local file path and name
        # * :remoteFolderPath represents remote folder relative to the root. Pass empty string for the root folder.
        def self.uploadFile(localFilePath, remoteFolderPath)
            fileName = File.basename(localFilePath)
            urlFile = $productURI + '/storage/file/' + fileName
            if not remoteFolderPath.empty?
                urlFile = $productURI + '/storage/file/' + remoteFolderPath + '/' + fileName
            end
            signedURL = Common::Utils.sign(urlFile)
            Common::Utils.uploadFileBinary(localFilePath, signedURL)
        end

        # Retrieves Files and Folder information from a remote folder. The method returns an Array of AppFile objects.
        # * :remoteFolderPath represents remote folder relative to the root. Pass empty string for the root folder.
        def self.getFiles(remoteFolderPath)
            urlFolder = $productURI + '/storage/folder'
            urlFile = ''
            urlExist = ''
            urlDisc = ''
            if not remoteFolderPath.empty?
                urlFile = $productURI + '/storage/folder/' + remoteFolderPath
            end
            signedURL = Common::Utils.sign(urlFolder)
            response = RestClient.get(signedURL, :accept => 'application/json')
            result = JSON.parse(response.body)
            apps = Array.new(result["Files"].size)

            for i in 0..result["Files"].size - 1
                apps[i] = AppFile.new
                apps[i].Name = result["Files"][i]["Name"]
                apps[i].IsFolder = result["Files"][i]["IsFolder"]
                apps[i].Size = result["Files"][i]["Size"]
                apps[i].ModifiedDate = Common::Utils.parse_date(result["Files"][i]["ModifiedDate"])
            end
            return apps
        end
    end
end
