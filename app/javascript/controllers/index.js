// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

// Third parties
// -----------------------------------------------------------------------------
import NestedForm from "stimulus-rails-nested-form"
application.register("nested-form", NestedForm)

// Components
// -----------------------------------------------------------------------------
import DropdownController from "../../components/ui/dropdown"
application.register("dropdown", DropdownController)

import ModalController from "../../components/ui/modal"
application.register("modal", ModalController)

import NotificationController from "../../components/ui/notification"
application.register("notification", NotificationController)

import TabsController from "../../components/ui/tabs"
application.register("tabs", TabsController)

// Controllers
// -----------------------------------------------------------------------------
import AutocompleteController from "./autocomplete_controller"
application.register("autocomplete", AutocompleteController)

import CopyTextController from "./copy_text_controller"
application.register("copy-text", CopyTextController)

import DirectUploadFieldController from "./direct_upload_field_controller"
application.register("direct-upload-field", DirectUploadFieldController)

import NavbarController from "./navbar_controller"
application.register("navbar", NavbarController)

import { PasswordVisibility, StrengthTestController } from "../../components/ui/form/password_field"

application.register('password-visibility', PasswordVisibility);
application.register("strength-test", StrengthTestController);
// import PasswordVisibility from "../../password_visibility_controller"
// application.register('password-visibility', PasswordVisibility)

// import StrenghTestController from "../../strength_test_controller"
// application.register("strength-test", StrenghTestController)

import SelectionController from "./selection_controller"
application.register("selection", SelectionController)

import SelectionGroupController from "./selection_group_controller"
application.register("selection-group", SelectionGroupController)

import SelectionRowController from "./selection_row_controller"
application.register("selection-row", SelectionRowController)

import SwitchController from "./switch_controller"
application.register("switch", SwitchController)

import ToggleController from "./toggle_controller"
application.register("toggle", ToggleController)

import HighlightController from "./highlight_controller"
application.register("highlight", HighlightController)

import UserFormController from "./user_form_controller"
application.register("user-form", UserFormController)
