all: clean brew virtualenv wstool fix-rosbag fix-rosbag-storage fix-python-qt-binding fix-bond-core fix-nodelet fix-common-tutorials fix-diagnostic-aggregator fix-filters fix-actionlib fix-vision-opencv fix-image-common build

brew:
	brew update
	brew cask install xquartz
	brew tap ros/deps
	brew tap osrf/simulation
	brew tap homebrew/core
	brew install cmake poco boost orocos-kdl sip pyqt gtest lz4 fltk urdfdom gpgme tinyxml2 boost-python opencv ogre assimp
	brew install yaml-cpp || brew link --overwrite yaml-cpp
	brew unlink gtest && brew link --overwrite gtest

virtualenv:
	pip install virtualenv
	virtualenv -p python2 .venv
	.venv/bin/pip install wstool rosdep rosinstall rosinstall_generator rospkg catkin-pkg sphinx empy nose numpy

wstool:
	.venv/bin/rosinstall_generator desktop --rosdistro melodic --deps --wet-only --tar > rosinstall
	.venv/bin/wstool init -j8 src rosinstall

build:
	. .venv/bin/activate \
		&& export PYTHONPATH=/usr/local/opt/sip/lib/python2.7/site-packages/:/usr/local/opt/pyqt/lib/python2.7/site-packages/ \
		&& export PATH=$$PATH:/usr/local/opt/qt/bin \
		&& export CPLUS_INCLUDE_PATH="$$CPLUS_INCLUDE_PATH:$(CURDIR)/.venv/include/python2.7" \
		&& ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release \
		  --cmake-args -DCMAKE_PREFIX_PATH=/usr/local/opt/qt/lib/cmake/ -DQt5_DIR=/usr/local/opt/qt/lib/cmake/Qt5 -DCMAKE_PREFIX_PATH=$(CURDIR)/install_isolated/

fix-rosbag:
	grep -q 'std=c++11' src/ros_comm/rosbag/CMakeLists.txt || sed -i '' -e 's/Wextra/Wextra;-std=c++11/' src/ros_comm/rosbag/CMakeLists.txt
	grep -q '/usr/local/opt/openssl/include' src/ros_comm/rosbag/CMakeLists.txt || sed -i '' -e 's|$${BZIP2_INCLUDE_DIR}|$${BZIP2_INCLUDE_DIR} /usr/local/opt/openssl/include|' src/ros_comm/rosbag/CMakeLists.txt

fix-rosbag-storage:
	grep -q 'std=c++11' src/ros_comm/rosbag_storage/CMakeLists.txt || sed -i '' -e 's/Wextra/Wextra;-std=c++11/' src/ros_comm/rosbag_storage/CMakeLists.txt
	grep -q '/usr/local/opt/openssl/include' src/ros_comm/rosbag_storage/CMakeLists.txt || sed -i '' -e 's|$${BZIP2_INCLUDE_DIR}|$${BZIP2_INCLUDE_DIR} /usr/local/opt/openssl/include|' src/ros_comm/rosbag_storage/CMakeLists.txt

fix-python-qt-binding:
	grep -q '/Qt5' src/python_qt_binding/cmake/sip_configure.py || sed -i '' -e 's|/PyQt5|/Qt5|' src/python_qt_binding/cmake/sip_configure.py

fix-bond-core:
	[[ -f kinetic-devel.tar.gz ]] || wget https://github.com/ros/bond_core/archive/kinetic-devel.tar.gz
	tar -xzf kinetic-devel.tar.gz
	rm -rf src/bond_core
	mv bond_core-kinetic-devel src/bond_core
	sed -i '' -e 's|$${UUID_INCLUDE_DIRS}||' src/bond_core/bondcpp/CMakeLists.txt

fix-nodelet:
	grep -q '$${UUID_INCLUDE_DIRS}' src/nodelet_core/nodelet/CMakeLists.txt && sed -i '' -e 's|$${UUID_INCLUDE_DIRS}||' src/nodelet_core/nodelet/CMakeLists.txt || exit 0
	grep -q 'set_directory_properties' src/nodelet_core/nodelet/CMakeLists.txt || awk '{ if ($$0 == "project(nodelet)") { print $$0 "\nset_directory_properties(PROPERTIES COMPILE_OPTIONS \"-std=c++11;\")" } else { print $$0 } }' src/nodelet_core/nodelet/CMakeLists.txt > .tmp && mv .tmp src/nodelet_core/nodelet/CMakeLists.txt

fix-common-tutorials:
	grep -q 'set_directory_properties' src/common_tutorials/nodelet_tutorial_math/CMakeLists.txt || awk '{ if ($$0 == "project(nodelet_tutorial_math)") { print $$0 "\nset_directory_properties(PROPERTIES COMPILE_OPTIONS \"-std=c++11;\")" } else { print $$0 } }' src/common_tutorials/nodelet_tutorial_math/CMakeLists.txt > .tmp && mv .tmp src/common_tutorials/nodelet_tutorial_math/CMakeLists.txt
	grep -q 'set_directory_properties' src/common_tutorials/pluginlib_tutorials/CMakeLists.txt || awk '{ if ($$0 == "project(pluginlib_tutorials)") { print $$0 "\nset_directory_properties(PROPERTIES COMPILE_OPTIONS \"-std=c++11;\")" } else { print $$0 } }' src/common_tutorials/pluginlib_tutorials/CMakeLists.txt > .tmp && mv .tmp src/common_tutorials/pluginlib_tutorials/CMakeLists.txt

fix-diagnostic-aggregator:
	grep -q 'set_directory_properties' src/diagnostics/diagnostic_aggregator/CMakeLists.txt || awk '{ if ($$0 == "project(diagnostic_aggregator)") { print $$0 "\nset_directory_properties(PROPERTIES COMPILE_OPTIONS \"-std=c++11;\")" } else { print $$0 } }' src/diagnostics/diagnostic_aggregator/CMakeLists.txt > .tmp && mv .tmp src/diagnostics/diagnostic_aggregator/CMakeLists.txt

fix-filters:
	grep -q 'set_directory_properties' src/filters/CMakeLists.txt || awk '{ if ($$0 == "project(filters)") { print $$0 "\nset_directory_properties(PROPERTIES COMPILE_OPTIONS \"-std=c++11;\")" } else { print $$0 } }' src/filters/CMakeLists.txt > .tmp && mv .tmp src/filters/CMakeLists.txt

fix-actionlib:
	[[ -f indigo-devel.tar.gz ]] || wget https://github.com/ros/actionlib/archive/indigo-devel.tar.gz
	tar -xzf indigo-devel.tar.gz
	rm -rf src/actionlib
	mv actionlib-indigo-devel src/actionlib

fix-vision-opencv:
	grep -q 'find_package(Boost REQUIRED python2.7)' src/vision_opencv/cv_bridge/CMakeLists.txt || sed -i '' -e 's|find_package(Boost REQUIRED python)|find_package(Boost REQUIRED python2.7)|' src/vision_opencv/cv_bridge/CMakeLists.txt

fix-image-common:
	grep -q 'set_directory_properties' src/image_common/image_transport/CMakeLists.txt || awk '{ if ($$0 == "project(image_transport)") { print $$0 "\nset_directory_properties(PROPERTIES COMPILE_OPTIONS \"-std=c++11;\")" } else { print $$0 } }' src/image_common/image_transport/CMakeLists.txt > .tmp && mv .tmp src/image_common/image_transport/CMakeLists.txt

clean:
	git clean -dfX
