configure_file(sleepy.desktop.template.in ${CMAKE_CURRENT_BINARY_DIR}/sleepy.desktop.template)

add_custom_target(desktop_file ALL
intltool-merge --quiet --desktop-style ${CMAKE_SOURCE_DIR}/po sleepy.desktop.template sleepy.desktop
)

#add_custom_command(
#OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/sleepy.desktop
#COMMAND 
#intltool-merge --quiet --desktop-style ${CMAKE_SOURCE_DIR}/po sleepy.desktop.template sleepy.desktop
##DEPENDS PO_FILES sleepy.desktop.template
#)

install(FILES
${CMAKE_CURRENT_BINARY_DIR}/sleepy.desktop
DESTINATION
    ${CMAKE_INSTALL_PREFIX}/share/applications/
)
