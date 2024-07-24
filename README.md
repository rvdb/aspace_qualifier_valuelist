# POC: Agent Qualifiers as Controlled Value List

## About

A proof-of-concept for an ArchivesSpace plugin that creates a controlled value list
for use in the Qualifier field in the (Parallel) Names section of Agent records.

## Installation

Install as you normally would and add `aspace_qualifier_valuelist` to
your list of enabled plugins in `AppConfig[:plugins]`.

Run the `setup-database` script before using since the plugin needs to update the
database.

The plugin does not have any additional dependencies so you do not need to run
the `initialize-plugin` script.

## Configuration
none

## Enhancements

### Staff Interface

The plugin turns the Qualifier field for the Name Forms and Parallel Names sections in Agent records to a dropdown select box, offering fixed values from a controlled value list.

## Enumerations

The plugin adds a new editable enumeration - `Name Qualifier`. If you add additional values to this
list, make sure that you also add translations in `frontend/locales/enums`.

## Note

The value of the Qualifier field is stored in the generated display name upon saving an agent record.
Should those values be changed in the translation file, these changes will only be picked up in the
display name of existing agent records when re-saving them.

## Disclaimer

Plugin developed as proof of concept by Ron Van den Branden [ron.vandenbranden@antwerpen.be], Letterenhuis, Antwerp, Belgium, primarily
intended for getting the hang of it, and ideally as inspiration for improvement. It comes without waranties or maintenance plan...