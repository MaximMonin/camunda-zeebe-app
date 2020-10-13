import Uploader from './uploader.js'

export default {
    upload (file, url) {
        const uploader = new Uploader(file, url)
        return uploader.upload()
    }
}
