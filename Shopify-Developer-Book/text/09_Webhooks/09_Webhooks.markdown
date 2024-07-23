## How to Handle WebHook Requests

This is a big, important topic. If Shopify doesn't receive a 200 OK status response within 10 seconds of sending a WebHook, Shopify will assume that there is a problem and will mark it as a failed attempt. Repeated attempts by Shopify will be made for up to 48 hours. Too many failures and the WebHook is deleted. A common cause for failure is by an app that performs too much complex processing when it receives requests, before responding. When processing WebHooks, a quick 200 OK response that acknowledges receipt of the data is essential.

Here's some pseudocode to demonstrate what I mean:

@@@ ruby
  def handle_webhook request
    # Note that the process_data call could take a while, e.g. 2-6 seconds
    process_data request.data

    status 200
  end
@@@

To make sure that you don't take too long before responding, you should defer processing the WebHook data until *after* the response has been sent. Delayed or background jobs are perfect for this.

Here's how your code could look:

@@@ ruby
  def handle_webhook request
    # This should take no time, so the overall response is quick
    schedule_processing request.data

    status 200
  end
@@@

Even if you're only doing a small amount of processing, there are other factors to take into account. On-demand cloud services, such as Heroku or PHPFog, will need to spin up a new processing node to handle sporadic requests. This is because they often put apps to sleep when they are not busy. Though this can only take several seconds, if your app is only spending five seconds processing data, it will still *fail* if the underlying server took five seconds to start up.

### The Interesting World of WebHooks

Shopify does a fine job of introducing and explaining WebHooks on the wiki and there are some pretty nifty use cases provided. The *best practices* are essential readings and should be thoroughly understood, in order to get the most out of using WebHooks. There are all sorts of interesting issues with WebHooks.

[Shopify WebHooks Documentation](http://wiki.shopify.com/WebHook#How_Should_I_Handle_Webhook_Requests)

When you are dealing with Shopify WebHooks, you are in the Email & Preferences section of a shop. You can setup a WebHook using the web interface. Pick the type of WebHook you want to use and provide a URL that will be receiving the data. For those without an app to hook up to a shop, there are some nifty WebHook testing sites available which are free. 

Let's take one quick example and use RequestBin. The first thing to do is create a WebHook listener at the [Request Bin](http://requestb.in/ "RequestBin") website.

<div class="figure">
  <img src="../images/request_bin_home2.png" alt="Create a new RequestBin for your WebHook" />
</div>


Pressing the *Create a RequestBin* button creates a new WebHook listener. A URL is generated, which can be used for testing. Note that one can also make this test private so that you are the only one who can see the WebHook results being sent to the RequestBin. 

<div class="figure">
  <img src="../images/request_bin_created2.png" alt="Newly Created RequestBin" />
</div>


The RequestBin listener is the URL that can be copied into the Shopify WebHook creation form at the shop's Email & Preferences administration section. For example, under [http://www.postbin.org/155tzv2](http://www.postbin.org/155tzv2), the code `155tzv2` was generated specifically for this test. Using the WebHook Create form, one can pick what type of WebHook to test and specify where to send it. 

<div class="figure">
  <img src="../images/webhook_created2.png" alt="WebHook Created in Shopify Email and Preferences" />
</div>


When the WebHook has been created, you can send it to the RequestBin service at any time by clicking on the **send test notification** link and standing by for a confirmation that it was indeed sent. 

<div class="figure">
  <img src="../images/webhook_testable2.png" alt="Testable WebHook" />
</div>


The links to delete and test a WebHook are beside each other. Exercise some caution when clicking in this neighbourhood! It is easy to accidentally press the trashcan icon and remove a WebHook that should *never be removed*. Oops! It can only take seconds of carelessness to decouple a shop from a crucial app.

Sending a test is easy, and the result should be immediately available in RequestBin. The example shows a test order in JSON format. 

<div class="figure">
  <img src="../images/webhook_results2.png" alt="WebHook Results" />
</div>


Looking closely at the sample order data which is in JSON format, there is a complete order to work with. The loop is closed on the concept of creating, testing and capturing WebHooks. The listener at RequestBin is a surrogate for a real one that would exist in an app but it can prove useful as a development tool. 

For the discussion of WebHook testing, note that the sample data from Shopify is good for testing connectivity but not for testing an app. Upon close examination, the data shows a lot of the fields are empty or null. It would be nice to be able send real data to an app, without the hassle of actually using the shop and booking orders. A real-life scenario might be to test and 

1. Ensure that the WebHook order data actually came from Shopify and that the source shop is correctly identified. 
2. Ensure that there is not already an identical order, as it makes no sense to process a *PAID* order two or more times.
3. Parse out the credit card, the shipping charges and the discount codes, if any. 
4. Parse out any product customization data in the cart note or cart attributes.

This small list introduces some issues that may not be obvious to new developers to the Shopify platform. Addressing each one will provide some useful insight into how to structure an app in order to deal with WebHooks from Shopify.

### WebHook Validation

When setting up an app in the Shopify Partner web application, the key attributes generated by Shopify is the authentication data. Every app has an API key to identify it, as well as a shared secret. These are unique tokens and are critical in providing a secure exchange of data between apps and Shopify. In the case of validating the source of a WebHook, both Shopify and the app can use the shared secret. When you use the API to install a WebHook into a shop, Shopify knows the identity of the app that is requesting the creation of a WebHook. Shopify uses the shared secret that is associated with the app and makes it part of the WebHook itself. Before Shopify sends off an app-created WebHook, it will use the shared secret to compute a Hash of the WebHook payload and embed this in the WebHook's HTTP headers. Any WebHook from Shopify that has been set up with the API will have `HTTP_X_SHOPIFY_HMAC_SHA256` in the HTTP request header. Since the app has access to the shared secret, it can use that to decode the incoming request. The Shopify team provides some working code for this.

@@@ ruby
SHARED_SECRET = "f10ad00c67b72550854a34dc166d9161"
def verify_webhook(data, hmac_header)
  digest = OpenSSL::Digest::Digest.new('sha256')
  hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, SHARED_SECRET, data)).strip

  hmac == hmac_header
end
@@@

The app calculates a value that only it could know. The header provides a value from Shopify. If the two computed values match, it is assured that the WebHook is valid and came from Shopify. This is why it is important to ensure that the shared secret is not widely distributed on the Internet. 

### Looking out for Duplicate WebHooks

As explained in the [WebHook best practices guide](http://wiki.shopify.com/WebHook#Best_Practices), Shopify will send out a WebHook and then wait for up to ten seconds for a response status. If that response is not received, the WebHook will be re-sent. This continues until a `200 OK` status is received, ensuring that even if a network connection is down, Shopify will keep trying to get the WebHook to the app, incrementally backing off on each retry to avoid slamming your app. If nothing changes within 48 hours, an email is sent to the app owner warning them that their WebHook receiver is not working and will be deleted from the shop. 

Assuming that all is well with the network and the app is receiving WebHooks, it is entirely possible that an app will receive the odd duplicate WebHook due to network funkiness. If you use the `tracert` command to examine hops to Shopify’s app servers, you can see the latency or time it takes for each hop. Sometimes, an overloaded router in the path will take a long time to forward the needed data. This extends the time it takes for a complete exchange to happen between Shopify and an app. Sometimes, the app itself can take a long time to process and respond to a WebHook. In any case, a duplicate is possible and the app might have a problem, unless it deals with the possibility of duplicates.

A simple way to deal with this might be to have the app record the ID of the incoming WebHook resource. For example, on a paid order, if the app knows a priori, that order 123456 is already processed, any further orders detected with the ID 123456 can be ignored. Turns out, in practice this is not a robust solution. A busy shop can inundate an app with orders or paid WebHooks and at any moment no matter how efficient the app is at processing those incoming WebHooks. There can be enough latency to ensure that Shopify sends a duplicate order out. 

A robust way to handle WebHooks is to put in place a Message Queue (MQ) service. All incoming WebHooks should be directed to a message queue. Once an incoming WebHook is successfully added to the queue, the app simply returns the `200 Status OK` response to Shopify and the WebHook is completed. If that process is subject to network latency or other issues, it makes no difference because the queue welcomes any and all WebHooks, duplicates or not. 

The app has a queue worker process which is used to *pop* WebHooks from the queue, for processing. That way, there is no longer a concern over processing speed and the app can do all of the sophisticated processing it needs to do. 

Also, it is possible to be certain whether a WebHook has been processed already or not. Duplicated WebHooks are best taken care of with this kind of architecture.

### Parsing WebHooks

Shopify provides WebHook requests as XML or JSON. Most scripting languages have XML and JSON parsers to make request processing easy. With the advent of NoSQL databases, storing JSON as documents in CouchDB or MongoDB is possible. It is also easy to use Node.js on the server to process WebHooks where JSON is a natural fit. Since the logic of searching a request for a specific field is the same for both formats, it is up to the app developer to choose the format they prefer. 

### Cart Customization

Without a doubt, one of the most useful but also more difficult aspects of front-end Shopify development, is in the use of the cart note and cart attribute features. They are the only way a shop can collect non-standard information from a customer. Any monogrammed handbags, initialed wedding invitations or engraved glass baby bottles will have used the cart note or cart attributes to capture and pass this information through the order process. Since a cart note or cart attribute is just a key and value, the value is restricted to a string. A string could be a simple name like "Bob" or it could conceivably be a sophisticated JavaScript Object like 

    [{"name": "Joe Blow", "age" : "29", "dob": "1958-01-29"},
     {"name": "Henrietta Booger", "age" : "19", "dob": "1978-05-21"},
     ...
     {"name": "Psilly Psilon", "age" : "39", "dob": "1968-06-03"}]

In the app, when parsing cart attributes with JSON, it is possible to reconstitute the original object embedded there. This pattern of augmenting orders with cart attributes and passing them to apps by WebHook for processing, has made it possible for the Shopify platform to deliver a wide variety of sites with unique features.
