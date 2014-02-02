# Instance for Modules/Classes

Modules and Classes have additional features not shared by other 
types of objects.

## Instance#method_definition

    um = String.instance.method_definition(:to_s)
    um.class.assert == UnboundMethod

## Instance#definition

The `#definition` method is just an alias for `#method_definition`.

    um = String.instance.definition(:to_s)
    um.class.assert == UnboundMethod

## Instance#method_definitions

    list = String.instance.method_definitions

Method definitions can be selected use support symbol selectors.

    list = String.instance.method_definitions(:public)
    list = String.instance.method_definitions(:protected)
    list = String.instance.method_definitions(:private)
    list = String.instance.method_definitions(:private, :protected)

## Instance#definitions

The `#definitions` method is likewise an alias for `#method_definitions`.

    list = String.instance.definitions

