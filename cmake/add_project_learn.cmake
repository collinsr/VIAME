
set( VIAME_PROJECT_LIST ${VIAME_PROJECT_LIST} learn )

set( LEARN_DIR ${VIAME_SOURCE_DIR}/packages/learn )

set( PYDENSECRF_DIR ${LEARN_DIR}-deps/pydensecrf )
set( PANOPTICAPI_DIR ${LEARN_DIR}-deps/panopticapi )

set( LEARN_BUILD_DIR ${VIAME_BUILD_PREFIX}/src/learn-build )

if( NOT EXISTS ${PYDENSECRF_DIR} )
  set( LEARN_CLONE_CMD git clone https://github.com/lucasb-eyer/pydensecrf.git ${PYDENSECRF_DIR} )
else()
  set( LEARN_CLONE_CMD git -C ${PYDENSECRF_DIR} pull )
endif()

if( NOT EXISTS ${PANOPTICAPI_DIR} )
  set( LEARN_CLONE_CMD ${LEARN_CLONE_CMD} &&
    git clone https://github.com/cocodataset/panopticapi.git ${PANOPTICAPI_DIR} )
else()
  set( LEARN_CLONE_CMD ${LEARN_CLONE_CMD} &&
    git -C ${PANOPTICAPI_DIR} pull )
endif()

if( NOT EXISTS ${LEARN_DIR} )
  set( LEARN_CLONE_CMD ${LEARN_CLONE_CMD} &&
    git clone --branch viame/master https://gitlab.kitware.com/darpa_learn/learn.git ${LEARN_DIR} )
else()
  set( LEARN_CLONE_CMD ${LEARN_CLONE_CMD} &&
    git -C ${LEARN_DIR} pull )
endif()

# Setup python env vars and commands
set( LEARN_REQ_PIP_CMD
    ${CMAKE_COMMAND} -E env "${PYTHON_DEP_ENV_VARS}"
    ${Python_EXECUTABLE} -m pip install --user )

if( VIAME_SYMLINK_PYTHON )
  set( LEARN_BUILD_CMD
    ${CMAKE_COMMAND} -E env "${PYTHON_DEP_ENV_VARS}"
    ${Python_EXECUTABLE} -m pip install --user -e . )
  set( LEARN_INSTALL_CMD )
else()
  # This is only required for no symlink install without a -e with older
  # versions of pip, for never versions the above command works with no -e
  set( LEARN_BUILD_CMD
    ${CMAKE_COMMAND} -E env "${PYTHON_DEP_ENV_VARS}"
    ${Python_EXECUTABLE} setup.py bdist_wheel -d ${LEARN_BUILD_DIR} )
  set( LEARN_INSTALL_CMD
    ${CMAKE_COMMAND} -E env "${PYTHON_DEP_ENV_VARS}"
    ${CMAKE_COMMAND} -DWHEEL_DIR=${LEARN_BUILD_DIR}
    -DPYTHON_EXECUTABLE=${Python_EXECUTABLE} -DPython_EXECUTABLE=${Python_EXECUTABLE}
    -P ${VIAME_CMAKE_DIR}/install_python_wheel.cmake )
endif()

# Install required dependencies and learn
ExternalProject_Add( learn
    DEPENDS python-deps detectron2 torchvideo
    PREFIX ${VIAME_BUILD_PREFIX}
    SOURCE_DIR ${VIAME_PACKAGES_DIR}
    CONFIGURE_COMMAND ${LEARN_CLONE_CMD}
    BUILD_COMMAND ${LEARN_REQ_PIP_CMD} -r ${LEARN_DIR}/requirements.txt
          COMMAND cd ${PYDENSECRF_DIR} && ${LEARN_BUILD_CMD}
          COMMAND cd ${PANOPTICAPI_DIR} && ${LEARN_BUILD_CMD}
          COMMAND cd ${LEARN_DIR} && ${LEARN_BUILD_CMD}
    INSTALL_COMMAND ${LEARN_INSTALL_CMD}
    LIST_SEPARATOR "----"
    )