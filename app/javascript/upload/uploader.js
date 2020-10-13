import { DirectUpload } from "@rails/activestorage"

export default class Uploader {
  constructor(file, url) {
    this.file = file
    this.url = url
    this.directUpload = new DirectUpload(this.file, this.url, this)
  }
 
  upload() {
    return new Promise((resolve, reject) => {
      this.directUpload.create((error, blob) => {
        if (error) {
          // Handle the error
          reject(error)
        } else {
          // Add an appropriately-named hidden input to the form
          // with a value of blob.signed_id
          resolve(blob)
        }
      })
    })
  }
}

