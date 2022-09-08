// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import AutocompleteController from "./components/autocomplete_controller"
application.register("autocomplete", AutocompleteController)

import DialogController from "./components/dialog_controller"
application.register("dialog", DialogController)

import DropdownController from "./components/dropdown_controller"
application.register("dropdown", DropdownController)

import NoscriptController from "./components/noscript_controller"
application.register("noscript", NoscriptController)

import NotificationController from "./components/notification_controller"
application.register("notification", NotificationController)

import SelectionController from "./components/selection_controller"
application.register("selection", SelectionController)

import SelectionGroupController from "./components/selection_group_controller"
application.register("selection-group", SelectionGroupController)

import SelectionRowController from "./components/selection_row_controller"
application.register("selection-row", SelectionRowController)

import UserFormController from "./forms/user_form_controller"
application.register("user-form", UserFormController)
