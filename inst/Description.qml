import QtQuick 		2.12
import JASP.Module 	1.0

Description
{
	name		: "jaspPlotBuilder"
	title		: qsTr("Plot builder")
	description	: qsTr("Build customizable plots with tidyplot")
	version			: "0.19.2"
	author		: "JASP Team"
	maintainer	: "JASP Team <jasp-stats.org>"
	website		: "jasp-stats.org"
	license		: "GPL (>= 2)"
	icon		: "icon.svg"
	hasWrappers	: false
	preloadData	: true

Analysis
	{
		title:  qsTr("Plot builder")
		qml:   	"jaspPlotBuilder.qml"
		func:	"jaspPlotBuilder"
		preloadData	: false

	}
}
