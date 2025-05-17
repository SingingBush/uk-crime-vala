UK Crime (Vala & GTK4)
======================

This project demonstrates how to use GTK4 with Vala. It makes use of the UK Police API to view information about various police forces and shows locations of recent crimes using a map view. It's a port of a Java equivelant: [uk-crime-javafx](https://github.com/SingingBush/uk-crime-javafx).

More info about Vala can be found on the [Vala documentation site](https://docs.vala.dev/). GTK 4 documentation can be found [here](https://docs.gtk.org/gtk4/index.html).

Also, there is a book named [Introducing Vala Programming](https://www.apress.com/9781484253793) which has [accompanying code on GitHub](https://github.com/Apress/introducing-vala-programming).

```
sudo dnf install gtk4-devel libsoup3-devel -y
```

# Compiling

The project is built using [Meson](https://mesonbuild.com)

### Using Meson

```
meson setup build --reconfigure
meson compile -C build
```

### Using valac directly

To compile with the Vala Compiler directly use:

```
valac --pkg gtk4 --pkg libsoup-3.0 --pkg json-glib-1.0 src/*.vala --output=ukcrime-gtk4
```