package controllers

import models.User
import play.api.mvc._
import play.api.http.HeaderNames
import play.api.templates.Txt

trait ControllerSpec {
  def getApi(user: Option[User]) = new Api with SecureController {
    override def authenticate(request: RequestHeader) = user
    override def getUser(request: RequestHeader) = user.get
    override def onUnauthorized = Action { req =>
      Results.Unauthorized(Txt("Invalid username/password specified"))
    }
  }
  def getLoggedInUser(group: String) = Some(new User("test", "*", group, "mock"))
}
