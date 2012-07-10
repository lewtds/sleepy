vala_precompile(VALA_C
SOURCES
	main.vala
	sleeptimer.vala
	trayicon.vala
	utility.vala
	wizard.vala
PACKAGES
    ${VALA_PKGS}
CUSTOM_VAPIS
	${CMAKE_SOURCE_DIR}/vapi/config.vapi
)


message(${VALA_C})
add_executable(sleepy, ${VALA_C})
