import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    options: { type: Array },
    label: {type: String, default: "value"},
    value: {type: String, default: "label"},
  }

  connect() {
    let options = {
      create: false,
      maxItems: 1
    }

    console.log(this.optionsValue)
    options.options = this.optionsValue
    options.labelField = this.labelValue
    options.searchField = this.labelValue
    options.valueField = this.valueValue

    this.select = new TomSelect(this.element, options)
  }

  disconnect() {
    this.select.destroy()
  }
}
