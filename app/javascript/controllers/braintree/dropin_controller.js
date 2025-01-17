import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dropin", "form" ]

  connect() {
    braintree.dropin.create({
      authorization: this.data.get("clientToken"),
      container: this.dropinTarget,
      card: {
        overrides: {
          styles: this.cardStyles
        }
      },
      //threeDSecure: true,
      paypal: {
        flow: "vault"
      },
      // Uncomment this to only display PayPal in the Drop-in UI
      //paymentOptionPriority: ['paypal']
    },
      this.clientCreated.bind(this)
    )
  }

  clientCreated(error, instance) {
    if (error) {
      console.error("Error setting up Braintree dropin:", error)
      return
    }

    this.instance = instance
  }

  submit(event) {
    event.preventDefault()
    this.instance.requestPaymentMethod(this.paymentMethod.bind(this))
  }

  paymentMethod(error, payload) {
    if (error) {
      console.error("Error with payment method:", error)
      return
    }

    this.addHiddenField("processor", "braintree")
    this.addHiddenField("payment_method_token", payload.nonce)
    this.formTarget.submit()
  }

  addHiddenField(name, value) {
    let hiddenInput = document.createElement("input")
    hiddenInput.setAttribute("type", "hidden")
    hiddenInput.setAttribute("name", name)
    hiddenInput.setAttribute("value", value)
    this.formTarget.appendChild(hiddenInput)
  }

  get cardStyles() {
    let darkMode = document.documentElement.classList.contains("dark");
    if(darkMode) {
      return {
        '.number': {
          color: 'white'
        },
        '.expirationDate': {
          color: 'white'
        }
      }
    }
  }
}
