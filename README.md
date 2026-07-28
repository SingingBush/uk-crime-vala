UK Crime (Vala & GTK4)
======================

[![build](https://github.com/SingingBush/uk-crime-vala/actions/workflows/build.yml/badge.svg)](https://github.com/SingingBush/uk-crime-vala/actions/workflows/build.yml)

This project demonstrates how to use GTK4 with Vala. It makes use of the UK Police API to view information about various police forces and shows locations of recent crimes using a map view. It's a port of a Java equivelant: [uk-crime-javafx](https://github.com/SingingBush/uk-crime-javafx).

More info about Vala can be found on the [Vala documentation site](https://docs.vala.dev/). GTK 4 documentation can be found [here](https://docs.gtk.org/gtk4/index.html).

There's also some good information on the now retired [Gnome Wiki](https://wiki.gnome.org/Projects/Vala/Tutorial)

Also, there is a book named [Introducing Vala Programming](https://www.apress.com/9781484253793) which has [accompanying code on GitHub](https://github.com/Apress/introducing-vala-programming).


# Compiling

You'll need a few dependencies as well as the Vala comiler and [Meson](https://mesonbuild.com).

```
sudo dnf install vala libvala gtk4-devel libsoup3-devel json-glib-devel libgee-devel -y
```

The project is built using [Meson](https://mesonbuild.com)

### Using Meson

```
meson setup build --reconfigure
meson compile -C build
```

### Using valac directly

To compile with the Vala Compiler directly use:

```
valac --pkg gtk4 --pkg gee-0.8 --pkg libsoup-3.0 --pkg json-glib-1.0 src/*.vala --output=ukcrime-gtk4
```