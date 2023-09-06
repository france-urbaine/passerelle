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
import NavbarController from "./components/navbar_controller"
application.register("navbar", NavbarController)

import AutocompleteController from "./components/autocomplete_controller"
application.register("autocomplete", AutocompleteController)

import ModalController from "./components/modal_controller"
application.register("modal", ModalController)

import DropdownController from "./components/dropdown_controller"
application.register("dropdown", DropdownController)

import NotificationController from "./components/notification_controller"
application.register("notification", NotificationController)

import PasswordVisibility from "./components/password_visibility_controller"
application.register('password-visibility', PasswordVisibility)

import SelectionController from "./components/selection_controller"
application.register("selection", SelectionController)

import SelectionGroupController from "./components/selection_group_controller"
application.register("selection-group", SelectionGroupController)

import SelectionRowController from "./components/selection_row_controller"
application.register("selection-row", SelectionRowController)

import StrenghTestController from "./components/strength_test_controller"
application.register("strength-test", StrenghTestController)

import SwitchController from "./components/switch_controller"
application.register("switch", SwitchController)

import CopyTextController from "./components/copy_text_controller"
application.register("copy-text", CopyTextController)

import ToggleClassController from "./components/toggle_class_controller"
application.register("toggle-class", ToggleClassController)

// Forms
// -----------------------------------------------------------------------------
import DirectUploadFieldController from "./forms/direct_upload_field_controller"
application.register("direct-upload-field", DirectUploadFieldController)

import UserFormController from "./forms/user_form_controller"
application.register("user-form", UserFormController)
