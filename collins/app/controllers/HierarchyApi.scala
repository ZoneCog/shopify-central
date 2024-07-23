package controllers

import models.{Asset,HierarchyInfo}
import util.config.Feature
import util.ApiTattler

import play.api.libs.json._
import play.api.data._
import play.api.data.Forms._
import play.api.http.{Status => StatusValues}
import play.api.libs.json.{JsBoolean, JsObject}
import play.api.mvc.Results
import java.sql.SQLException


trait HierarchyApi {
  this: Api with SecureController =>


  case class HierarchyForm( child_tag: String,  start: Option[Int] = None, end: Option[Int] = None) {
    def merge(asset: Asset) =  {
      val child = Asset.findByTag(child_tag).get
      HierarchyInfo.createOrUpdate(asset,child_tag, child_start=start, child_end = end)
      ApiTattler.notice(child, None, "Moving %s to %s".format(child_tag, asset.tag))
    }
  }
  val HIERARCHY_FORM = Form(
    mapping(
      "child_tag" -> text,
      "start" -> optional(number),
      "end" -> optional(number)
    )(HierarchyForm.apply)(HierarchyForm.unapply)
  )

  def updateHierarchyValues(tag: String) = SecureAction { implicit req =>
    Api.withAssetFromTag(tag) { asset =>
      HIERARCHY_FORM.bindFromRequest.fold(
        hasErrors => {
          val error = hasErrors.errors.map { _.message }.mkString(", ")
          Left(Api.getErrorMessage("Data submission error: %s".format(error)))
        },
        hierarchyForm => {
          try {
            hierarchyForm.merge(asset)
            Right(ResponseData(Results.Ok, JsObject(Seq("SUCCESS" -> JsBoolean(true)))))
          } catch {
            case e: SQLException =>
              Left(Api.getErrorMessage("Erorr updating tag",
                Results.Status(StatusValues.CONFLICT)))
            case e =>
              Left(Api.getErrorMessage("Incomplete form submission: %s".format(e.getMessage)))
          }
        }
      )
    }.fold(
      err => formatResponseData(err),
      suc => formatResponseData(suc)
    )
  }(Permissions.HierarchyApi.UpdateHierarchy)



  def deleteHierarchyLink(tag: String, child_tag: String ) = SecureAction { implicit req =>
    val asset = Asset.findByTag(tag).get
    val child = Asset.findByTag(child_tag).get
    HierarchyInfo.deleteLink(asset.id, child.id)
    ApiTattler.notice(child, None, "Removing %s from %s".format(child_tag, tag))
    val js = JsObject(Seq("SUCCESS" -> JsBoolean(true)))
    formatResponseData(ResponseData(Results.Ok, JsObject(Seq("SUCCESS" -> JsBoolean(true)))))
  }(Permissions.HierarchyApi.UpdateHierarchy)

  def getChildren(tag: String) = SecureAction { implicit req =>
    var asset = Asset.findByTag(tag).get
    var children = HierarchyInfo.findChildren(asset.id)
    val js = JsObject(Seq("values" -> JsArray(children.map(JsNumber(_)))))
    formatResponseData(ResponseData(Results.Ok,js))
  }(Permissions.HierarchyApi.UpdateHierarchy)

  def getParent(tag: String) = SecureAction { implicit req =>
    var asset = Asset.findByTag(tag).get
    var parent = HierarchyInfo.findParent(asset.id).get
    val js = JsObject(Seq("values" -> (JsNumber(parent))))
    formatResponseData(ResponseData(Results.Ok, js ))
  }(Permissions.HierarchyApi.UpdateHierarchy)

  def getAllNodes() = SecureAction { implicit req =>
    var nodes = HierarchyInfo.getAllNodes()
    val js = JsObject(Seq("values" -> JsArray(nodes.map(_.asJsonObj ))))
    formatResponseData(ResponseData(Results.Ok,js))
  }(Permissions.HierarchyApi.UpdateHierarchy)


/*
  def getTagValues(tag: String) = SecureAction { implicit req =>
    val response =
      AssetMeta.findByName(tag).map { m =>
        if (Feature.encryptedTags.map(_.name).contains(m.name)) {
          Api.getErrorMessage("Refusing to give backs values for %s".format(m.name))
        } else {
          val s: Set[String] = AssetMetaValue.findByMeta(m).sorted.toSet
          val js = JsObject(Seq("values" -> JsArray(s.toList.map(JsString(_)))))
          ResponseData(Results.Ok, js)
        }
      }.getOrElse(Api.getErrorMessage("Tag not found", Results.NotFound))
    formatResponseData(response)
  }(Permissions.TagApi.GetTagValues)

*/

}
