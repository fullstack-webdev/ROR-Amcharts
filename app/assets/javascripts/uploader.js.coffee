jQuery ->
  connectUploadEvents()

  #        if $(e.target).attr('multiple') == 'false'

connectUploadEvents = ->
  $('[id=fileupload]').live "DOMActivate", ->
    if $('#multifileupload').length == 0
      $(this).fileupload
        add: (e, data) ->
          #types = /(\.|\/)(*)$/i
          file = data.files[0]
          if true # types.test(file.type) || types.test(file.name)
            $(e.target).find(".document-info").hide()
            $(e.target).find(".upload-controls").hide()
            data.context = $(tmpl("template-upload", file))
            $(e.target).append(data.context)
            data.submit()
          else
            alert("#{file.name} is not a doc, docx, txt, xls, xlsx, or pdf file")

        progress: (e, data) ->
          if data.context
            progress = parseInt(data.loaded / data.total * 100, 10)
            data.context.find('.bar').css('width', progress + '%')

        done: (e, data) ->
          $(e.target).find('.document-upload-updating').removeClass 'hidden'
          #$(e.target).find('.document-info').show()
          #$(e.target).find(".upload-controls").show()
          documentId = $(e.target).find('.upload-controls').attr('id').replace('div_upload_', '')
          filename = $(e.target).find('.document-name').text()
          file = data.files[0]
          domain = $(e.target).attr('action')
          path = $(e.target).find('input[name=key]').val().replace('${filename}', file.name)
          #path = $(e.target).find('input[name=key]').val().replace('${filename}', documentId + ": " + filename + "." + file.name.substr((file.name.lastIndexOf('.') + 1)))
          to = $(e.target).data('post')
          content = {}
          content[$(e.target).data('as')] = path

          $.ajax
            url: to
            dataType: "script"
            data: content
            type: "PUT"
            success: ->
              $(this).addClass "done"

          data.context.remove() if data.context # remove progress bar

        fail: (e, data) ->
          $(e.target).find('.document-info').show()
          $(e.target).find(".upload-controls").show()
          data.context.remove()
          alert("#{data.files[0].name} failed to upload.")
          console.log("Upload failed:")
          console.log(data)

  $('[id=multifileupload]').live "DOMActivate", ->
    $(this).fileupload
      add: (e, data) ->
        #types = /(\.|\/)(*)$/i
        file = data.files[0]

        if true # types.test(file.type) || types.test(file.name)
          #$(e.target).find(".document-info").hide()
          #$(e.target).find(".upload-controls").hide()

          temp_id = Math.random()
          $.ajax "/documents/new",
            data: { "multi": true, "job_id": $(this).attr("data-job"), "name": "#{file.name}", "temp_id": temp_id  }
            type: "get"
            dataType: "script"
            success: (d2) ->
              new_element = $(".root-document[data-temp-id='#{temp_id}']")
              new_element.find(".document-info").hide()
              data.context = $(tmpl("template-upload", file))
              new_element.find('.upload-controls').append(data.context)
              data.submit()
              return
        else
          alert("#{file.name} is not a doc, docx, txt, xls, xlsx, or pdf file")

      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.context.find('.bar').css('width', progress + '%')

      done: (e, data) ->
        new_element = data.context.closest('.root-document')
        new_element.find('.document-upload-updating').removeClass 'hidden'
        #$(e.target).find('.document-info').show()
        #$(e.target).find(".upload-controls").show()
        documentId = new_element.attr('id').replace('document_', '')
        filename = new_element.find('.document-name').text()
        file = data.files[0]
        upload_form = $('#multiuploader').find('form')
        domain = upload_form.attr('action')
        path = upload_form.find('input[name=key]').val().replace('${filename}', file.name)
        #path = $(e.target).find('input[name=key]').val().replace('${filename}', documentId + ": " + filename + "." + file.name.substr((file.name.lastIndexOf('.') + 1)))
        to = upload_form.data('post')
        content = {}
        content[upload_form.data('as')] = path

        $.ajax
          url: "/documents/#{documentId}"
          dataType: "script"
          data: content
          type: "PUT"
          success: ->
            $(this).addClass "done"

        data.context.remove() if data.context # remove progress bar

      fail: (e, data) ->
        new_element = data.context.closest('.root-document')
        new_element.find('.document-info').show()
        new_element.find(".upload-controls").show()
        data.context.remove()
        alert("#{data.files[0].name} failed to upload.")
        console.log("Upload failed:")
        console.log(data)
