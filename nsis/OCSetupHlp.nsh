;
; OCSetupHlp.nsh
; --------------
;
; OpenCandy Helper Include File
;
; This file defines a few macros that need to be called
; from your main installer script in order to initialize
; and setup OpenCandy.
;
; Please consult the accompanying SDK documentation for
; integration details and contact partner support for
; assistance with any advanced integration needs.
;
; IMPORTANT:
; ----------
; Publishers should have no need to modify the content
; of this file. If you are modifying this file for any
; reason other than as directed by partner support
; you are probably making a mistake. Please contact
; partner support instead.
;
; Note: When using the Unicode NSIS compiler this file
;       must be re-saved with UTF-16LE/UCS-2LE encoding
;       for versions of Unicode NSIS up to 2.42.3,
;       and either UTF16-LE/UCS2LE or UTF8 encoding
;       for versions thereafter.
;
; Copyright (c) 2008 - 2014 SweetLabs, Inc.
;

!ifdef _OCSETUPHLP_NSH
!ifndef OC_WARNING_DISABLE_MULTIPLE_INCLUDE
!warning "OCSetupHlp.nsh is included more than once"
!endif
!else
!define _OCSETUPHLP_NSH

!ifndef OC_WARNING_DISABLE_COMPILER_NOT_UNICODE
	!ifndef NSIS_UNICODE
		!warning     "OpenCandy: We strongly recommend compiling with the Unicode NSIS compiler."
		!ifdef NSIS_PACKEDVERSION
			!if ${NSIS_PACKEDVERSION} >= 0x03000000
			!warning "OpenCandy: Set 'Unicode true' at the very top of your .nsi script."
			!else
			!warning "OpenCandy: Install and compile using Unicode NSIS from www.scratchpaper.com ."
			!endif
		!else
			!warning "OpenCandy: Install and compile using Unicode NSIS from www.scratchpaper.com ."
		!endif
	!endif
!endif



;--------------------------------
; Include and prepare NSIS libraries used
;--------------------------------

!include WinMessages.nsh
!include FileFunc.nsh
!include nsDialogs.nsh
!include LogicLib.nsh
!insertmacro GetParameters



;--------------------------------
; OpenCandy definitions
;--------------------------------

; This macro helps keeps default definitions tidy.
!macro _OCDefaultDefinition DEFNAME DEFVALUE
	!ifndef ${DEFNAME}
	!define ${DEFNAME} '${DEFVALUE}'
	!endif
!macroend

; Size of strings (including terminating character)
!define OC_STR_CHARS  1024
!define OC_GUID_CHARS   33

; Alignment options for Skip and Decline controls.
!define OC_CTRL_ALIGN_LEFT          1 ; Left align to reference window
!define OC_CTRL_ALIGN_RIGHT         2 ; Right align to reference window
!define OC_CTRL_ALIGN_BELOW_WINDOW  4 ; Align below reference window
!define OC_CTRL_ALIGN_ABOVE_WINDOW  8 ; Align above reference window
!define OC_CTRL_ALIGN_VCENTER      16 ; Use with OC_CTRL_ALIGN_BELOW_WINDOW or OC_CTRL_ALIGN_ABOVE_WINDOW to align on reference window border
!define OC_CTRL_ALIGN_ONBORDER     32 ; Use with OC_CTRL_ALIGN_BELOW_WINDOW or OC_CTRL_ALIGN_ABOVE_WINDOW to align on reference window border
!define OC_USE_BUTTON_CONTROL      64 ; Will show OpenCandy's Skip offers control as a button rather than as active text

; OpenCandy window adjust modes
!define OC_ADJUSTMODE_SIMPLE            0
!define OC_ADJUSTMODE_DPICENTERINPARENT 1
!define OC_ADJUSTMODE_DPIPOSITIONINSELF 2 ; Param1 is x position (0-100), Param 2 is y position (0-100)

; OpenCandy window position
!insertmacro _OCDefaultDefinition OC_WND_OFFSET_X         13
!insertmacro _OCDefaultDefinition OC_WND_OFFSET_Y         67
!insertmacro _OCDefaultDefinition OC_WND_ADJUST_PARAM1    50
!insertmacro _OCDefaultDefinition OC_WND_ADJUST_PARAM2    50
!insertmacro _OCDefaultDefinition OC_WND_WIDTH           470
!insertmacro _OCDefaultDefinition OC_WND_HEIGHT          228
!insertmacro _OCDefaultDefinition OC_WND_ADJUST_MODE     ${OC_ADJUSTMODE_DPICENTERINPARENT}

; Decline control attributes
!insertmacro _OCDefaultDefinition OC_CTRL_DECLINE_OFFSET_X  12
!insertmacro _OCDefaultDefinition OC_CTRL_DECLINE_OFFSET_Y   0
!insertmacro _OCDefaultDefinition OC_CTRL_DECLINE_FONT_NAME ''
!insertmacro _OCDefaultDefinition OC_CTRL_DECLINE_FONT_SIZE  0
!insertmacro _OCDefaultDefinition OC_CTRL_DECLINE_ALIGNMENT ${OC_CTRL_ALIGN_LEFT}

; Skip control attributes
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_OFFSET_X          5
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_BUTTON_OFFSET_X        10
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_OFFSET_Y          2
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_BUTTON_OFFSET_Y         0
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_FONT_NAME        ''
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_BUTTON_FONT_NAME       ''
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_FONT_SIZE         0
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_BUTTON_FONT_SIZE        0
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_TEXTCOLOR        ''
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_BUTTON_TEXTCOLOR       ''
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_BGCOLOR          ''
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_BUTTON_BGCOLOR         ''
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_MSG_CUSTOM       ''
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_BUTTON_MSG_CUSTOM      ''
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_LINE_ENABLE       1
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_LINE_FGCOLOR     ''
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_UNDERLINE_ENABLE  1
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_ATEXT_ALIGNMENT        ${OC_CTRL_ALIGN_LEFT}
!insertmacro _OCDefaultDefinition OC_CTRL_SKIP_BUTTON_ALIGNMENT       ${OC_CTRL_ALIGN_LEFT}

; Values used with OCInit2A(), OCInit2W() APIs
!define OC_INIT_SUCCESS        0
!define OC_INIT_ASYNC_ENABLE   1
!define OC_INIT_ASYNC_DISABLE  0
!define OC_INIT_MODE_NORMAL    0
!define OC_INIT_MODE_REMNANT   1

; Options controlling OpenCandy initialization
!define OC_INIT_PERFORM_NOW         0
!define OC_INIT_PERFORM_BYPAGEORDER 1
!define OC_INIT_PROGRESSBAR_OFF     0
!define OC_INIT_PROGRESSBAR_ON      1

; Values used with OCSetNoCandy() API
!define OC_NOCANDY 1

; Values used with OCGetNoCandy() API
!define OC_CANDY_ENABLED  0
!define OC_CANDY_DISABLED 1

; Values used with PublisherMayReboot() API
!define OC_REBOOT_MAYREBOOT_ENABLED  1
!define OC_REBOOT_MAYREBOOT_DISABLED 0

; Offer types returned by OCGetOfferType() API
!define OC_OFFER_TYPE_NORMAL   1
!define OC_OFFER_TYPE_EMBEDDED 2

; Offer types passed to StartOfferDownloads
!define OC_OFFER_TYPE_FILTER_ALL      0
!define OC_OFFER_TYPE_FILTER_NORMAL   1
!define OC_OFFER_TYPE_FILTER_EMBEDDED 2

; User choice indicators returned by OCGetOfferState() API
!define OC_OFFER_CHOICE_ACCEPTED  1
!define OC_OFFER_CHOICE_DECLINED  0
!define OC_OFFER_CHOICE_NOCHOICE -1

; Values used with OCCanLeaveOfferPage() API
!define OC_OFFER_LEAVEPAGE_ALLOWED    1
!define OC_OFFER_LEAVEPAGE_DISALLOWED 0

; Values used for OCGetAsyncOfferStatus() API
!define OC_OFFER_STATUS_CANOFFER_READY         0
!define OC_OFFER_STATUS_CANOFFER_NOTREADY      1
!define OC_OFFER_STATUS_QUERYING_NOTREADY      2
!define OC_OFFER_STATUS_NOOFFERSAVAILABLE      3
!define OC_STATUS_QUERY_GENERAL                0
!define OC_STATUS_QUERY_DETERMINESOFFERENABLED 1

; Values used with OCGetBannerInfo() API
!define OC_OFFER_BANNER_USEADTEXT_ON  1
!define OC_OFFER_BANNER_USEADTEXT_OFF 0

; Values returned by OCGetBannerInfo() API
!define OC_OFFER_BANNER_FOUNDNEITHER     0
!define OC_OFFER_BANNER_FOUNDTITLE       1
!define OC_OFFER_BANNER_FOUNDDESCRIPTION 2
!define OC_OFFER_BANNER_FOUNDBOTH        3

; Values returned by OCRunDialog() API
!define OC_OFFER_RUN_DIALOG_FAILURE -1

; Values for LogDevModeMessage() API
!define OC_DEVMSG_ERROR_TRUE  1
!define OC_DEVMSG_ERROR_FALSE 0

; Values used for SetOCOfferEnabled() API
!define OC_OFFER_ENABLE_TRUE  1
!define OC_OFFER_ENABLE_FALSE 0

; Values returned by OCLoadOpenCandyDLL() API
!define OC_LOADOCDLL_FAILURE 0

; Values for SetUseDefaultColorBkGrnd() API
!define OC_USE_DEFAULT_COLOR_BKGRND_ON  1
!define OC_USE_DEFAULT_COLOR_BKGRND_OFF 0

; Values for CheckSkipAllButtonStatus() API
!define OC_CONTROL_SKIP_USED   1
!define OC_CONTROL_SKIP_UNUSED 0

; Values for CheckDeclineOfferButtonStatus() API
!define OC_CONTROL_DECLINE_USED   1
!define OC_CONTROL_DECLINE_UNUSED 0

; Values for GetIsRequired() API
!define OC_REQUIRED_NO 0
!define OC_GLOBAL_NO   0

; Values for SkipOffer() API
!define OC_SKIPPED_NOSKIP               0
!define OC_SKIPPED_OCSKIPOWNERSCREEN    1
!define OC_SKIPPED_OPENCANDYDECLINE     2
!define OC_SKIPPED_3RDPARTYSKIP         3
!define OC_SKIPPED_OCSKIPNONOWNERSCREEN 4

; Settings for OpenCandy Ad Policy
!define OC_AP_DECLINE_SHOW_ONALL                 1 ; Always display a Decline control regardless of whether the OpenCandy offer itself requires its presence.
!define OC_AP_SKIPALL_SHOW_ONFIRST               2 ; Display a Skip control on the first OpenCandy offer page only if there is more than one offer present.
!define OC_AP_SKIPALL_SHOW_ONALL                 4 ; Always display a Skip control on OpenCandy offer pages when there is more than one offer present.
!define OC_AP_SKIPALL_DRAW_BUTTON                8 ; Draw a button for the OpenCandy Skip control instead of active text.
!define OC_AP_SKIPALL_INCLUDES_PREVIOUS         16 ; When the user clicks a Skip control, any previously accepted OpenCandy offers are also skipped.
!define OC_AP_BANNER_ADTEXT_ENABLE              32 ; Set whether the OpenCandy offer should display the text 'Advertised by ...' as its banner subtext.
!define OC_AP_SEQUENCE_EXTOFFER_BEFOREOCOFFER   64 ; Inform OpenCandy that an external offer will be shown before an OpenCandy offer
!define OC_AP_SEQUENCE_EXTOFFER_AFTEROCOFFER   128 ; Inform OpenCandy that an external offer will be shown after an OpenCandy offer

; Convenience values for OpenCandy Ad Policy
!define OC_AP_PRESET_GOOGLECLIENTAPP            45 ; Google Client Application (OC_AP_DECLINE_SHOW_ONALL | OC_AP_SKIPALL_SHOW_ONALL | OC_AP_SKIPALL_DRAW_BUTTON | OC_AP_BANNER_ADTEXT_ENABLE)
!define OC_AP_PRESET_GOOGLEADWORDS               2 ; Google AdWords (OC_AP_SKIPALL_SHOW_ONFIRST)

; Experimental settings for OpenCandy Ad Policy
!define OC_AP_SKIPALL_SHOW_EXCLUDEONLAST       256 ; Don't draw a Skip control on the last of a series of offer pages

; Publisher recieves from SkipNotify
!define OC_SKIPNOTIFICATION_SHOWN_NOTACTIVATED 0
!define OC_SKIPNOTIFICATION_SHOWN_ACTIVATED    1

; Internal skip states
!define OC_SKIPSTATE_NOTSKIPPED                       0
!define OC_SKIPSTATE_SKIPPED_OPENCANDY_OWNERSCREEN    1
!define OC_SKIPSTATE_SKIPPED_OPENCANDY_NONOWNERSCREEN 2
!define OC_SKIPSTATE_SKIPPED_EXTERNAL                 3

; Skip button display formats
!define OC_SKIPFMT_NOTSHOWN 0
!define OC_SKIPFMT_BUTTON   1
!define OC_SKIPFMT_ATEXT    2

; Reserved values
!define OC_INSTANCE_DISPLAYEDFIRST_NOTSET 0
!define OC_LOADINGSCREEN_NOTACTIVE        0
!define OC_OFFERPAGE_NOTACTIVE            0

; Flags used in NSIS script
!define OC_NSIS_TRUE  1
!define OC_NSIS_FALSE 0

; Maximum number of offers Opencandy can display
;
; Note: The following points may require patching:
;       1. OpenCandyInsertAllOfferPages
;       2. OpenCandyAPIDoChecks
;
!define OC_MAX_OFFERS 4

; Send message timeout
!define OC_SENDMSG_TIMEOUT 5000

;
; IMPORTANT:
; Do not modify these definitions or disable the warnings below.
; If you see warnings when you compile your script you must
; modify the values you set where you !insertmacro OpenCandyAsyncInit
; (i.e. in your .nsi file) before releasing your installer publicly.
!define OC_SAMPLE_KEY    "bc2485da3a5aa04e413f6d848fb8f762"
!define OC_SAMPLE_SECRET "5b4172384aa04baad7c542c5e77add41"

; Default keys incase publisher does not define them
!insertmacro _OCDefaultDefinition OC_STR_KEY     ""
!insertmacro _OCDefaultDefinition OC_STR_SECRET  ""


;--------------------------------
; OpenCandy defaults
;--------------------------------

; DLL relocation support
!ifndef OC_OCSETUPHLP_FILE_PATH
	!warning "Do not forget to define OC_OCSETUPHLP_FILE_PATH in your script. Defaulting to 'OCSetupHlp.dll'."
	!define OC_OCSETUPHLP_FILE_PATH ".\OCSetupHlp.dll"
!endif

; OC_MAX_INIT_TIME_* is the maximum time in milliseconds that OCInit may block when fetching offers.
; If you intend to override these default do so by defining them in your .nsi file before !include'ing this header.
; Be certain to make OpenCandy partner support aware of any override you apply because this can affect your metrics.
!insertmacro _OCDefaultDefinition OC_MAX_INIT_TIME_INIT_PERFORM_NOW         8000
!insertmacro _OCDefaultDefinition OC_MAX_INIT_TIME_INIT_PERFORM_BYPAGEORDER    0

; OC_MAX_LOADING_TIME_* is the maximum time in milliseconds that the loading page may be displayed.
; Note that under normal network conditions the loading page may end sooner. Setting this value too low
; may reduce offer rate. Values of at least 5000 are recommended. If you intend to override these defaults do so by
; defining them in your .nsi file before !include'ing this header. Be certain to make OpenCandy partner support aware
; of any override you apply because this can affect your metrics.
!insertmacro _OCDefaultDefinition OC_MAX_LOADING_TIME_INIT_PERFORM_NOW          8000
!insertmacro _OCDefaultDefinition OC_MAX_LOADING_TIME_INIT_PERFORM_BYPAGEORDER 10000

; OC_MAX_LOADING_OFFER_COUNT is the maximum number of offers for which the loading screen will
; wait to become ready. Once this number of offers is ready the loading screen will end.
!insertmacro _OCDefaultDefinition OC_MAX_LOADING_OFFER_COUNT 2

; These values are the defaults for the loading screen UI. If you intend to override them do so by
; defining them in your .nsi file before !include'ing this header. Note that you may use LangStrings
; to support localization.
!insertmacro _OCDefaultDefinition OC_LOADING_SCREEN_CAPTION     " "
!insertmacro _OCDefaultDefinition OC_LOADING_SCREEN_DESCRIPTION " "
!insertmacro _OCDefaultDefinition OC_LOADING_SCREEN_MESSAGE     "Loading..."
!insertmacro _OCDefaultDefinition OC_LOADING_SCREEN_FONTFACE    "Arial"
!insertmacro _OCDefaultDefinition OC_LOADING_SCREEN_FONTSIZE    100

; This value controls whether a progress bar is shown while the OpenCandy SDK initializes if initialization is
; configured to block for a limited period of time. If you intend to override this default do so by defining
; it your .nsi file before !include'ing this header.
!insertmacro _OCDefaultDefinition OC_INIT_PROGRESSBAR_ENABLE ${OC_INIT_PROGRESSBAR_OFF}

; This value prevents the progress bar from being displayed until the blocking time has exceeded the threshold.
; If you intend to override this default do so by defining it your .nsi file before !include'ing this header.
!insertmacro _OCDefaultDefinition OC_INIT_PROGRESSBAR_DELAY 4

; OC_CAPTION_MACRO_NAME is the name of the macro that will be used to set the
; caption and subcaption on the OpenCandy offer screen. This happens at display time.
; The macro must be of this form:
;
;   !macro MyCustomCaptionSetterMacro CAPTION SUBCAPTION
;
; The macro name must be defined before your script includes the OCSetupHlp.nsh header and it must
; be stack and variable safe - that is the state of the stack and the variables must be unchanged
; after the macro code. If you are unsure how to write such code then _do not_ attempt to do so because
; this may have _serious_ repercussions on the reliability of OpenCandy and of your own installer.
; If you write your own setter macro you should send the macro code to the OpenCandy SDK product
; team via OpenCandy partner support for verification.
;
; These caption macros are built-in:
;
;   _OC_CAPTION_MACRO_BUILTIN_MUI      - Compatible with ModernUI, ModernUI2, UltraModernUI libraries (default)
;   _OC_CAPTION_MACRO_BUILTIN_NSIS     - Compatible with the basic NSIS UI framework
;   _OC_CAPTION_MACRO_BUILTIN_DISABLED - Disables caption setting
;
; If you intend to override the default do so by defining it in your .nsi file before #include'ing this header.
!insertmacro _OCDefaultDefinition OC_CAPTION_MACRO_NAME _OC_CAPTION_MACRO_BUILTIN_MUI

; Caption and subcaption dialog item IDs and settings for use with _OC_CAPTION_MACRO_BUILTIN_NSIS
!ifndef OC_CAPTION_BUILTIN_NSIS_CAPTION_DISABLED
	!insertmacro _OCDefaultDefinition OC_CAPTION_BUILTIN_NSIS_CAPTION_DLGID    1037
!endif
!ifndef OC_CAPTION_BUILTIN_NSIS_SUBCAPTION_DISABLED
	!insertmacro _OCDefaultDefinition OC_CAPTION_BUILTIN_NSIS_SUBCAPTION_DLGID 1038
!endif

;--------------------------------
; OpenCandy global variables
;--------------------------------

; IMPORTANT:
; ----------
; Never modify or reference these variables directly in any other script,
; they are used completely internally to this helper script and are subject
; to change without notice at any time.

Var OCArrayOfferAttached
Var OCArrayOfferIsEnabled
Var OCArrayUseOfferPage
Var OCArrayHasReachedOfferPage
Var OCArrayShownOfferPage
Var OCArrayHasPerformedExecOfferEmbedded
Var OCArraySkipState
Var OCNoCandy
Var OCAPIGuid
Var OCMemMapGuid
Var OCInitProductKey
Var OCInitProductSecret
Var OCInitMode
Var OCHasBeenInitialized
Var OCInitPerformInit
Var OCInitOffersRequested
Var OCProductInstallSuccess
Var OCHasShownLoadingScreen
Var OCLoadingScreenActivity
Var OCLoadingScreenHWND
Var OCInstanceDisplayedFirst
Var OCActiveOfferPage
Var OCAdPolicyFlags
Var OCSkipControlAttached
Var OCUseDefaultColorBkGround
Var OCCustomBrushColor
Var OCCustomImagePath
!ifdef OC_REBOOT_PROTOTYPE
Var OCSetPublisherMayReboot
!endif


;--------------------------------
; OpenCandy functions and macros
;--------------------------------

;
; _OCClampInt
; -----------
; This macro is internal to this helper script. Do not insert it in your own code.
;

!macro _OCClampInt VALUE MIN MAX
	${If} ${VALUE} < ${MIN}
		Push ${MIN}
	${ElseIf} ${VALUE} > ${MAX}
		Push ${MAX}
	${Else}
		Push ${Value}
	${EndIf}
!macroend



;
; _OCMinInt
; ---------
; This macro is internal to this helper script. Do not insert it in your own code.
;

!macro _OCMinInt VAL1 VAL2
	${If} ${VAL1} < ${VAL2}
		Push ${VAL1}
	${Else}
		Push ${VAL2}
	${EndIf}
!macroend



;
; _OpenCandyCheckInstance
; -----------------------
; This macro is internal to this helper script. Do not insert it in your own code.
;

!macro _OpenCandyCheckInstance OC_INSTANCE
	!if ${OC_INSTANCE} < 1
		!define TMP_OC_INVALIDINSTANCE
	!endif
	!if ${OC_INSTANCE} > ${OC_MAX_OFFERS}
		!define TMP_OC_INVALIDINSTANCE
	!endif
	!ifdef TMP_OC_INVALIDINSTANCE
		!error "Value for OC_INSTANCE must be from 1 to ${OC_MAX_OFFERS}! (was: ${OC_INSTANCE})"
		!undef TMP_OC_INVALIDINSTANCE
	!endif
!macroend



;
; _OC_CAPTION_MACRO_BUILTIN_MUI
; -----------------------------
; This macro is internal to this helper script. Do not insert it in your
; own code. Sets the caption and subcaption strings (banner text).
;
; This macro is compatible with ModernUI, ModernUI2, UltraModernUI libraries.
;

!macro _OC_CAPTION_MACRO_BUILTIN_MUI CAPTION SUBCAPTION
	!ifmacrondef MUI_HEADER_TEXT
		!error "The macro MUI_HEADER_TEXT was not found. Include your UI framework header before OCSetupHlp.nsh. If you are not using a framework that provides MUI_HEADER_TEXT consult the description of OC_CAPTION_MACRO_NAME in OCSetupHlp.nsh and/or contact OpenCandy partner support for assistance."
	!endif
	Push "${SUBCAPTION}"
	Push "${CAPTION}"
	Exch $0
	Exch 1
	Exch $1
	!insertmacro MUI_HEADER_TEXT $0 $1
	Pop $1
	Pop $0
!macroend



;
; _OC_CAPTION_MACRO_BUILTIN_NSIS
; ------------------------------
; This macro is internal to this helper script. Do not insert it in your
; own code. Sets the caption and subcaption strings (banner text).
;
; This macro is compatible with the basic NSIS UI framework.
;
; The following definitions can be overridden before you !include OCSetupHlp.nsh:
;
;   OC_CAPTION_BUILTIN_NSIS_CAPTION_DISABLED    # If defined, do not try to set caption text
;   OC_CAPTION_BUILTIN_NSIS_SUBCAPTION_DISABLED # If defined, do not try to set subcaption text
;   OC_CAPTION_BUILTIN_NSIS_CAPTION_DLGID       # The ID of the dialog control that should be updated with the caption text
;   OC_CAPTION_BUILTIN_NSIS_SUBCAPTION_DLGID    # The ID of the dialog control that should be updated with the subcaption text
;
; Usage:
;
;   !define OC_CAPTION_MACRO_NAME _OC_CAPTION_MACRO_BUILTIN_NSIS
;   !include OCSetupHlp.nsh
;

!macro _OC_CAPTION_MACRO_BUILTIN_NSIS CAPTION SUBCAPTION
	Push "${SUBCAPTION}"
	Push "${CAPTION}"
	Exch $0
	Exch 1
	Exch $1
	Push $2
	!ifndef OC_CAPTION_BUILTIN_NSIS_CAPTION_DISABLED
		GetDlgItem $2 $HWNDPARENT ${OC_CAPTION_BUILTIN_NSIS_CAPTION_DLGID}
		${If} $2 <> 0
			SendMessage $2 ${WM_SETTEXT} 0 "STR:$0" /TIMEOUT=${OC_SENDMSG_TIMEOUT}
		${Endif}
	!endif
	!ifndef OC_CAPTION_BUILTIN_NSIS_SUBCAPTION_DISABLED
		GetDlgItem $2 $HWNDPARENT ${OC_CAPTION_BUILTIN_NSIS_SUBCAPTION_DLGID}
		${If} $2 <> 0
			SendMessage $2 ${WM_SETTEXT} 0 "STR:$1" /TIMEOUT=${OC_SENDMSG_TIMEOUT}
		${Endif}
	!endif
	Pop $2
	Pop $1
	Pop $0
!macroend



;
; _OC_CAPTION_MACRO_BUILTIN_DISABLED
; ----------------------------------
; This macro is internal to this helper script. Do not insert it in your
; own code. Avoids setting the caption and subcaption strings (banner text).
;
; Usage:
;
;   !define OC_CAPTION_MACRO_NAME _OC_CAPTION_MACRO_BUILTIN_DISABLED
;   !include OCSetupHlp.nsh
;

!macro _OC_CAPTION_MACRO_BUILTIN_DISABLED CAPTION SUBCAPTION
!macroend



;
; OpenCandy API check
; -------------------
; Perform a basic sanity check to ensure that your script
; inserts all mandatory API calls. Any failures will be
; shown as warnings from the compiler at compile time.
;
; To perform this check, insert the OpenCandyAPIDoChecks
; macro at the very bottom of your .nsi file.
;
; The _OpenCandyAPIInserted and _OpenCandyAPICheckInserted
; macros are internal to this helper script, do not insert
; them in your code.
;
; Usage:
;
;   # Have the compiler perform some basic OpenCandy API implementation checks
;   # This macro must be inserted at the very end of the .nsi script,
;   # outside any other code blocks.
;   !insertmacro OpenCandyAPIDoChecks
;

!macro _OpenCandyAPIInserted APINAME
	; Add a definition to note insertion of API name
	!ifndef _OC_APICHECK_INSERTED_${APINAME}
		!define _OC_APICHECK_INSERTED_${APINAME}
	!endif
!macroend

!macro _OpenCandyAPICheckInserted APINAME WARNMSG
	; Check an API name was inserted, show a warning otherwise
	!ifndef _OC_APICHECK_INSERTED_${APINAME}
		!if "${WARNMSG}" != ""
			!warning "Did not find reference to required API ${APINAME}. ${WARNMSG}"
		!else
			!warning "Did not find reference to required API ${APINAME}."
		!endif
	!endif
!macroend

!macro OpenCandyAPIDoChecks
	; Check only for mandatory API names
	!insertmacro _OpenCandyAPICheckInserted OpenCandyAsyncInit       "Check that you have inserted OpenCandyAsyncInit in your .onInit callback function, after any language selection code."
	!insertmacro _OpenCandyAPICheckInserted OpenCandyLoadDLLPage     "Check that you have inserted OpenCandyLoadDLLPage in your list of installer pages (e.g. before OpenCandyConnectPage)."
	!insertmacro _OpenCandyAPICheckInserted OpenCandyConnectPage     "Check that you have inserted OpenCandyConnectPage in your list of installer pages (e.g. before OpenCandyOfferPage)."
	!insertmacro _OpenCandyAPICheckInserted OpenCandyOfferPage1      "Check that you have inserted OpenCandyOfferPage 1 in your list of installer pages (e.g. before instfiles)."
	!if ${OC_MAX_OFFERS} >= 2
	!insertmacro _OpenCandyAPICheckInserted OpenCandyOfferPage2      "Check that you have inserted OpenCandyOfferPage 2 in your list of installer pages (e.g. before instfiles)."
	!endif
	!if ${OC_MAX_OFFERS} >= 3
	!insertmacro _OpenCandyAPICheckInserted OpenCandyOfferPage3      "Check that you have inserted OpenCandyOfferPage 3 in your list of installer pages (e.g. before instfiles)."
	!endif
	!if ${OC_MAX_OFFERS} >= 4
	!insertmacro _OpenCandyAPICheckInserted OpenCandyOfferPage4      "Check that you have inserted OpenCandyOfferPage 4 in your list of installer pages (e.g. before instfiles)."
	!endif
	!insertmacro _OpenCandyAPICheckInserted OpenCandyOnInstSuccess   "Check that you have inserted OpenCandyOnInstSuccess in your .onInstSuccess callback function."
	!insertmacro _OpenCandyAPICheckInserted OpenCandyOnGuiEnd        "Check that you have inserted OpenCandyOnGuiEnd in your .onGUIEnd callback function."
	!insertmacro _OpenCandyAPICheckInserted OpenCandyInstallEmbedded "Check that you have inserted OpenCandyInstallEmbedded in a section that will run during your product installation."
!macroend



;
; OpenCandyReserveFile
; --------------------
; Insert this macro as close to the top of your .nsi file as possible
; after including this header, before other functions and sections that
; include "File" directives. This will reserve a place early in the
; file data block for OCSetupHlp.dll. Because the DLL is required in
; the .onInit callback function the reservation will make your installer
; launch faster and allow more time for fetching offer information.
;
; Usage:
;
;   # Improve startup performance and increase offer fetch time by
;   # reserving an early place in the file data block for OpenCandy DLL.
;   !insertmacro OpenCandyReserveFile
;

!macro OpenCandyReserveFile
	ReserveFile "${OC_OCSETUPHLP_FILE_PATH}"
!macroend



; --------------------------------
; Begin: OpenCandy Array Functions
; --------------------------------

!define OC_ARRAY_PTR_SIZE 4
!define OC_ARRAY_INT_SIZE 4
!define OC_ARRAY_MAX_ELEMENTS 1024

;
; __OCArrayAllocFn
; ----------------
; Do not use this function directly. Instead, see _OCArrayAlloc.
;
; Usage:
;
;   Push <element init value>
;   Push <number of elements>
;   Call _OCArrayAllocFn
;   Pop <OCArray>
;

Function __OCArrayAllocFn
	Exch $1 ; Elements
	Exch
	Exch $2 ; Init value
	Exch
	Push $0 ; OCArray
	Exch 2
	${If} $1 < 1
	${OrIf} $1 > ${OC_ARRAY_MAX_ELEMENTS}
		StrCpy $0 ""
	${Else}
		Push $r0
		; Allocate primary array structure
		IntOp $r0 $1 * ${OC_ARRAY_PTR_SIZE}
		IntOp $r0 $r0 + ${OC_ARRAY_INT_SIZE}
		Push $3 ; Cached error state
		StrCpy $3 0
		${If} ${Errors}
			StrCpy $3 1
		${EndIf}
		System::Alloc $r0
		Pop $0
		${If} ${Errors} ; Handle System.dll failed to load
			StrCpy $0 0
		${EndIf}
		${If} $3 = 1
			SetErrors
		${EndIf}
		Pop $3
		${If} $0 = 0
			; Error allocating OCArray
			StrCpy $0 ""
		${Else}
			System::Call "*$0(i r1)"
			; Allocate initialized element buffers
			IntOp $r0 $0 + ${OC_ARRAY_INT_SIZE}
			Push $r1
			${For} $r1 1 $1
				!ifdef NSIS_UNICODE
					System::Call "*(&w${NSIS_MAX_STRLEN} '$2')i .s"
				!else
					System::Call "*(&m${NSIS_MAX_STRLEN} '$2')i .s"
				!endif
				Exch $r2
				${If} $r2 = 0
					; Error allocating OCArray element, free everything
					IntOp $r0 $0 + ${OC_ARRAY_INT_SIZE}
					IntOp $r2 $r1 - 1
					Push $r3
					${For} $r1 1 $r2
						System::Call "*$r0(i .r13)"
						System::Free $r3
						IntOp $r0 $r0 + ${OC_ARRAY_PTR_SIZE}
					${Next}
					Pop $r3
					Pop $r2
					System::Free $0
					StrCpy $0 ""
					${Break}
				${Else}
					System::Call "*$r0(i r12)"
					Pop $r2
					IntOp $r0 $r0 + ${OC_ARRAY_PTR_SIZE}
				${EndIf}
			${Next}
			Pop $r1
		${EndIf}
		Pop $r0
	${EndIf}
	${If} $0 == ""
		SetErrors
	${EndIf}
	Pop  $2
	Pop  $1
	Exch $0
FunctionEnd



;
; _OCArrayAlloc
; -------------
; Allocates an OCArray.
;
; An OCArray is a one-based, fixed-size array whose elements
; are of the same type and size as an NSIS string for the
; active compiler.
;
; Upon error, _OCArrayAlloc will return an empty string value and
; the error flag will be set.
;
; Usage:
;
;   # Allocate an OCArray with 4 elements and an empty string as the initial value of each element
;   Var /GLOBAL MyArray
;   !insertmacro _OCArrayAlloc $MyArray 4
;

!macro _OCArrayAlloc VARNAME ELEMENTS INITVALUE
	Push "${INITVALUE}"
	Push "${ELEMENTS}"
	Call __OCArrayAllocFn
	Pop ${VARNAME}
!macroend



;
; __OCArrayGetValueFn
; -------------------
; Do not use this function directly. Instead, see _OCArrayGetValue.
;
; Retrieve the value of an OCArray element.
;
; Usage:
;
;   Push <number of element>
;   Push <OCArray>
;   Call _OCArrayGetValueFn
;   Pop <element value>
;

Function __OCArrayGetValueFn
	Exch $0 ; OCArray
	Exch
	Exch $1 ; Element
	${If} $0 = 0
	${OrIf} $1 < 1
		StrCpy $0 ""
		SetErrors
	${Else}
		Push $r0
		System::Call "*$0(i .r10)"
		${If} $r0 < $1
			StrCpy $0 ""
			SetErrors
		${Else}
			IntOp $r0 $1 - 1
			IntOp $r0 $r0 * ${OC_ARRAY_PTR_SIZE}
			IntOp $r0 $r0 + ${OC_ARRAY_INT_SIZE}
			IntOp $r0 $r0 + $0
			System::Call "*$r0(i .r10)"
			!ifdef NSIS_UNICODE
				System::Call "*$r0(&w${NSIS_MAX_STRLEN} .s)"
			!else
				System::Call "*$r0(&m${NSIS_MAX_STRLEN} .s)"
			!endif
			Pop $0
		${EndIf}
		Pop $r0
	${EndIf}
	Pop $1
	Exch $0
FunctionEnd



;
; _OCArrayGetValue
; ----------------
; Retrieves a value from an OCArray.
;
; Upon error, _OCArrayGetValue will return an empty string and
; the error flag will be set.
;
; Usage:
;
;   # Retrieve the third element of an OCArray into $0
;   !insertmacro _OCArrayGetValue $MyArray 3 $0
;

!macro _OCArrayGetValue VARNAME ELEMENT OUTVAR
	Push "${ELEMENT}"
	Push "${VARNAME}"
	Call __OCArrayGetValueFn
	Pop ${OUTVAR}
!macroend



;
; __OCArraySetValueFn
; -------------------
; Do not use this function directly. Instead, see _OCArraySetValue.
;
; Retrieve the value of an OCArray element.
;
; Usage:
;
;   Push <element value>
;   Push <number of element>
;   Push <OCArray>
;   Call _OCArrayGetValueFn
;

Function __OCArraySetValueFn
	Exch $0 ; OCArray
	Exch
	Exch $1 ; Element
	Exch 2
	Exch $2 ; Value

	${If} $0 = 0
	${OrIf} $1 < 1
		SetErrors
	${Else}
		Push $r0
		System::Call "*$0(i .r10)"
		${If} $r0 < $1
			SetErrors
		${Else}
			IntOp $r0 $1 - 1
			IntOp $r0 $r0 * ${OC_ARRAY_PTR_SIZE}
			IntOp $r0 $r0 + ${OC_ARRAY_INT_SIZE}
			IntOp $r0 $r0 + $0
			System::Call "*$r0(i .r10)"
			!ifdef NSIS_UNICODE
				System::Call "*$r0(&w${NSIS_MAX_STRLEN} '$2')"
			!else
				System::Call "*$r0(&m${NSIS_MAX_STRLEN} '$2')"
			!endif
		${EndIf}
		Pop $r0
	${EndIf}
	Pop $2
	Pop $0
	Pop $1
FunctionEnd



;
; _OCArraySetValue
; ----------------
; Stores a value in an OCArray element.
;
; Upon error the error flag will be set.
;
; Usage:
;
;   # Set the third element of an OCArray
;   !insertmacro _OCArraySetValue $MyArray 3 "This is a string stored in element 3"
;

!macro _OCArraySetValue VARNAME ELEMENT VALUE
	Push "${VALUE}"
	Push "${ELEMENT}"
	Push "${VARNAME}"
	Call __OCArraySetValueFn
!macroend



;
; __OOCArrayFreeFn
; ----------------
; Do not use this function directly. Instead, see _OCArrayFree.
;
; Free an OCArray.
;
; Usage:
;
;   Push <OCArray>
;   Call __OOCArrayFreeFn
;

Function __OOCArrayFreeFn
	Exch $0 ; OCArray
	${If} $0 = 0
		SetErrors
	${Else}
		Push $r0
		Push $r1
		Push $r2
		Push $r3
		System::Call "*$0(i .r10)"
		IntOp $r1 $0 + ${OC_ARRAY_INT_SIZE}
		${For} $r2 1 $r0
			System::Call "*$r1(i .r13)"
			System::Free $r3
			IntOp $r1 $r1 + ${OC_ARRAY_PTR_SIZE}
		${Next}
		Pop $r3
		Pop $r2
		Pop $r1
		Pop $r0
		System::Free $0
	${EndIf}
	Pop $0
FunctionEnd



;
; _OCArrayFree
; ------------
; Deletes an OCArray, destroying its contents and releasing
; its allocated memory.
;
; Upon error the error flag will be set.
;
; Usage:
;
;   # Free an OCArray
;   !insertmacro _OCArrayFree $MyArray
;

!macro _OCArrayFree VARNAME
	Push "${VARNAME}"
	Call __OOCArrayFreeFn
!macroend

; ------------------------------
; End: OpenCandy Array Functions
; ------------------------------



;
; _OpenCandyPrepareNSISAPI
; ------------------------
; This macro is internal to this helper script. Do not
; insert it in your own code.
;
; Prepares the OpenCandy API by loading initializing state for the NSIS
; interface layer. This macro must execute before any other macro code
; or function.
;
; Usage:
;
;   !insertmacro _OpenCandyPrepareNSISAPI
;

!macro _OpenCandyPrepareNSISAPI
	ClearErrors
	!insertmacro _OCArrayAlloc $OCArrayOfferAttached                 ${OC_MAX_OFFERS} ${OC_NSIS_FALSE}
	!insertmacro _OCArrayAlloc $OCArrayOfferIsEnabled                ${OC_MAX_OFFERS} ${OC_NSIS_TRUE}
	!insertmacro _OCArrayAlloc $OCArrayUseOfferPage                  ${OC_MAX_OFFERS} ${OC_NSIS_FALSE}
	!insertmacro _OCArrayAlloc $OCArrayHasReachedOfferPage           ${OC_MAX_OFFERS} ${OC_NSIS_FALSE}
	!insertmacro _OCArrayAlloc $OCArrayShownOfferPage                ${OC_MAX_OFFERS} ${OC_NSIS_FALSE}
	!insertmacro _OCArrayAlloc $OCArrayHasPerformedExecOfferEmbedded ${OC_MAX_OFFERS} ${OC_NSIS_FALSE}
	!insertmacro _OCArrayAlloc $OCArraySkipState                     ${OC_MAX_OFFERS} ${OC_SKIPSTATE_NOTSKIPPED}
	StrCpy $OCNoCandy ${OC_NSIS_FALSE}
	${If} ${Errors}
		StrCpy $OCNoCandy ${OC_NSIS_TRUE}
	${EndIf}
	StrCpy $OCAPIGuid ""
	StrCpy $OCMemMapGuid ""
	StrCpy $OCInitProductKey ""
	StrCpy $OCInitProductSecret ""
	StrCpy $OCInitMode ${OC_INIT_MODE_NORMAL}
	StrCpy $OCHasBeenInitialized ${OC_NSIS_FALSE}
	StrCpy $OCInitPerformInit ${OC_INIT_PERFORM_NOW}
	StrCpy $OCInitOffersRequested ${OC_MAX_OFFERS}
	StrCpy $OCProductInstallSuccess ${OC_NSIS_FALSE}
	StrCpy $OCHasShownLoadingScreen ${OC_NSIS_FALSE}
	StrCpy $OCLoadingScreenActivity ${OC_LOADINGSCREEN_NOTACTIVE}
	StrCpy $OCLoadingScreenHWND 0
	StrCpy $OCInstanceDisplayedFirst ${OC_INSTANCE_DISPLAYEDFIRST_NOTSET}
	StrCpy $OCActiveOfferPage ${OC_OFFERPAGE_NOTACTIVE}
	StrCpy $OCAdPolicyFlags 0
	StrCpy $OCSkipControlAttached ${OC_NSIS_FALSE}
	StrCpy $OCUseDefaultColorBkGround ${OC_NSIS_TRUE}
	StrCpy $OCCustomBrushColor ""
	StrCpy $OCCustomImagePath ""
	!ifdef OC_REBOOT_PROTOTYPE
	StrCpy $OCSetPublisherMayReboot ${OC_NSIS_FALSE}
	!endif
!macroend



;
; _OpenCandyTeardownNSISAPI
; -------------------------
; This macro is internal to this helper script. Do not
; insert it in your own code.
;
; Frees resources used by the OpenCandy for NSIS layer and clears
; certain variables to improve safety against invalid API calls.
; The OpenCandy client library should be unloaded before this
; macro code executes.
;
; Usage:
;
;   !insertmacro _OpenCandyTeardownNSISAPI
;

!macro _OpenCandyTeardownNSISAPI
	!insertmacro _OCArrayFree $OCArrayOfferAttached
	!insertmacro _OCArrayFree $OCArrayOfferIsEnabled
	!insertmacro _OCArrayFree $OCArrayUseOfferPage
	!insertmacro _OCArrayFree $OCArrayHasReachedOfferPage
	!insertmacro _OCArrayFree $OCArrayShownOfferPage
	!insertmacro _OCArrayFree $OCArrayHasPerformedExecOfferEmbedded
	!insertmacro _OCArrayFree $OCArraySkipState
	StrCpy $OCNoCandy ${OC_NSIS_TRUE}
	StrCpy $OCHasBeenInitialized ${OC_NSIS_FALSE}
	StrCpy $OCAPIGuid ""
!macroend



;
; _OpenCandyDevModeMsg
; --------------------
; This macro is internal to this helper script. Do not insert it in your own code.
;
; Parameters:
;
;   OC_DEV_MSG   : Message to display (string)
;   OC_DEV_ERROR : The message represents an error OC_NSIS_TRUE or OC_NSIS_FALSE
;   OC_FAQ_ID    : ID of the FAQ associated with the message, or 0 if there is no FAQ associated (int)
;
; Usage:
;
;   # Send an error message to the dev window for offer one
;   !insertmacro _OpenCandyDevModeMsg "This is an error with associated FAQ #500" ${OC_NSIS_TRUE} 500
;

!macro _OpenCandyDevModeMsg OC_DEV_MSG OC_DEV_ERROR OC_FAQ_ID
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCAPIGuid != ""
		Push $0
		StrCpy $0 "${OC_DEV_MSG}"
		!if ${OC_DEV_ERROR} == ${OC_NSIS_TRUE}
			!define OC_TMP_DEV_ERROR ${OC_DEVMSG_ERROR_TRUE}
			StrCpy $0 "{\rtf1 {\colortbl;\red0\green0\blue0;\red255\green0\blue0;}\cf2Status ERROR! \cf1 $0\par}"
		!else if ${OC_DEV_ERROR} == ${OC_NSIS_FALSE}
			!define OC_TMP_DEV_ERROR ${OC_DEVMSG_ERROR_FALSE}
		!else
			!error "Value for OC_DEV_ERROR must be either OC_NSIS_TRUE or OC_NSIS_FALSE!"
		!endif
		!ifdef NSIS_UNICODE
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy39(m, w, i, i, i)v ('$OCAPIGuid', r0, ${OC_TMP_DEV_ERROR}, ${OC_FAQ_ID}, 0) ? c"
		!else
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy38(m, m, i, i, i)v ('$OCAPIGuid', r0, ${OC_TMP_DEV_ERROR}, ${OC_FAQ_ID}, 0) ? c"
		!endif
		Pop $0
		!undef OC_TMP_DEV_ERROR
	${EndIf}
!macroend



;
; SetOCOfferEnabled
; -----------------
; Allows you to disable one or both OpenCandy offer screens easily from your
; installer code. Note that this is not the recommended method - you
; ought to determine during initialization whether OpenCandy should be
; disabled and specify an appropriate mode when inserting OpenCandyAsyncInit
; in that case. If you must use this method please be sure to inform the OpenCandy
; partner support team. Never directly place your own logical conditions around other
; OpenCandy functions and macros because this can have unforeseen consequences.
;
; You can use this macro only after calling OpenCandyAsyncInit and before the
; end user navigates to the OpenCandy offer screen.
;
; Parameters:
;
;   OC_INSTANCE       : The OpenCandy offer screen that is being configured (1 - 4)
;   OC_OFFER_ENABLED  : Whether the offer is enabled or not (OC_NSIS_TRUE or OC_NSIS_FALSE)
;
; Notes:
;
;   OC_OFFER_ENABLED == ${OC_NSIS_TRUE} is no longer supported.
;
; Usage:
;
;   # Turns off OpenCandy offer screen one after initialization
;   !insertmacro SetOCOfferEnabled 1 ${OC_NSIS_FALSE}
;

!macro SetOCOfferEnabled OC_INSTANCE OC_OFFER_ENABLED
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} ${OC_OFFER_ENABLED} == ${OC_NSIS_FALSE}
	${AndIf} ${OC_INSTANCE} > 0
	${AndIf} ${OC_INSTANCE} <= $OCInitOffersRequested
		Push ${OC_OFFER_ENABLED}
		Push ${OC_INSTANCE}
		Exch $0 ; Offer
		Exch
		Exch $1 ; Enabled?
		Push $r0
		!insertmacro _OCArrayGetValue $OCArrayShownOfferPage ${OC_INSTANCE} $r0
		${If} ${OC_NSIS_FALSE} == $r0 # ShownOfferPage
			!insertmacro _OCArraySetValue $OCArrayOfferIsEnabled ${OC_INSTANCE} ${OC_OFFER_ENABLE_FALSE}
			${If} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
				Push $0
				IntOp $0 ${OC_INSTANCE} - 1
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy37(m, i, i)v ('$OCAPIGuid', ${OC_OFFER_ENABLE_FALSE}, r0) ? c"
				Pop $0
			${EndIf}
		${EndIf}
		Pop $r0
		Pop $1
		Pop $0
	${EndIf}
!macroend



;
; OpenCandySetUseDefaultColorBkgrnd
; ---------------------------------
; Calling this procedure after the OpenCandyAsyncInit macro in the .onInit function
; tells the client whether to draw the OpenCandy loading and offer screens on the solid
; Windows system color COLOR_3DFACE. The OpenCandy loading screen takes the same
; configuration as the first enabled, non-remnant OpenCandy offer screen.
;
; Parameters:
;
;   OC_USE_DEFAULT  : Use the default solid background color? (OC_NSIS_TRUE or OC_NSIS_FALSE)
;
; Usage:
;
;   # Do not use default solid background color for OpenCandy offer screen one
;   !insertmacro OpenCandySetUseDefaultColorBkgrnd ${OC_NSIS_FALSE}
;

!macro OpenCandySetUseDefaultColorBkgrnd OC_USE_DEFAULT
	${If} "${OC_USE_DEFAULT}" == "${OC_NSIS_TRUE}"
	${OrIf} "${OC_USE_DEFAULT}" == "${OC_NSIS_FALSE}"
		StrCpy $OCUseDefaultColorBkGround ${OC_USE_DEFAULT}
		${If} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
			${If} $OCUseDefaultColorBkGround == ${OC_NSIS_TRUE}
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy44(m, i)v ('$OCAPIGuid', ${OC_USE_DEFAULT_COLOR_BKGRND_ON}) ? c"
			${Else}
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy44(m, i)v ('$OCAPIGuid', ${OC_USE_DEFAULT_COLOR_BKGRND_OFF}) ? c"
			${EndIf}
		${EndIf}
	${EndIf}
!macroend



;
; OpenCandySetCustomBrushColor
; ----------------------------
; Calling this procedure after the OpenCandyAsyncInit macro in  the .onInit function
; tells the client to draw the OpenCandy loading and offer screens on the specified
; solid background color. The OpenCandy loading screen takes the same configuration
; as the first enabled, non-remnant OpenCandy offer screen.
;
; Parameters:
;
;   szColor     : The solid background color to draw on, in '#RGB' form, where R, G, B
;                 are each zero-padded hex values in range 00-FF.
;
; Usage:
;
;   # Draw offer one on solid red background color
;   !insertmacro OpenCandySetCustomBrushColor "#FF0000"
;

!macro OpenCandySetCustomBrushColor szColor
	StrCpy $OCCustomBrushColor "${szColor}"
	${If} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
		!ifdef NSIS_UNICODE
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy46(m, w)v ('$OCAPIGuid', '$OCCustomBrushColor') ? c"
		!else
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy45(m, m)v ('$OCAPIGuid', '$OCCustomBrushColor') ? c"
		!endif
	${EndIf}
!macroend



;
; OpenCandyCustomImagePath
; ------------------------
; Calling this procedure after the OpenCandyAsyncInit macro in the .onInit function
; tells the client to load a background image from the specified file, which should be a
; fully-qualified path, and composite the OpenCandy loading and offer screens upon it.
; The OpenCandy loading screen takes the same configuration as the first enabled, non-remnant
; OpenCandy offer screen. The image dimensions should match those of the main installer window.
;
; Parameters:
;
;   szImagePath : A fully-qualified path to the background image.
;
; Usage:
;
;   # Set a custom image background for OpenCandy offer screen one
;   !insertmacro OpenCandyCustomImagePath "$PLUGINSDIR\MyInstallerBackground.png"
;

!macro OpenCandyCustomImagePath szImagePath
	StrCpy $OCCustomImagePath "${szImagePath}"
	${If} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
		!ifdef NSIS_UNICODE
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy55(m, w)v ('$OCAPIGuid', '$OCCustomImagePath') ? c"
		!else
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy54(m, m)v ('$OCAPIGuid', '$OCCustomImagePath') ? c"
		!endif
	${EndIf}
!macroend



;
; _OCSetNoCandy
; -------------
; This macro is internal to this helper script. Do not insert it in your own code.
;

!macro _OCSetNoCandy
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
		${If} $OCAPIGuid != ""
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy33(m, i)i ('$OCAPIGuid', ${OC_NOCANDY}).n ? c"
		${EndIf}
	${EndIf}
	StrCpy $OCNoCandy ${OC_NSIS_TRUE}
!macroend



;
; _OpenCandyLoadDLL
; -----------------
; This macro is internal to this helper script. Do not insert it in your own code.
;

!macro _OpenCandyLoadDLL
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCAPIGuid == ""

		; Prevent loading multiple instances
		!ifdef NSIS_UNICODE
		System::Call /NOUNLOAD "$SYSDIR\Kernel32.dll::GetModuleHandleW(w)i ('OCSetupHlp.dll').s"
		!else
		System::Call /NOUNLOAD "$SYSDIR\Kernel32.dll::GetModuleHandleA(m)i ('OCSetupHlp.dll').s"
		!endif
		Exch $0
		InitPluginsDir
		${If} $0 <> 0
		${OrIf} ${FileExists} "$PLUGINSDIR\OCSetupHlp.dll"
			Pop $0
		${Else}
			Pop $0

			Push $0
			StrCpy $0 ${OC_LOADOCDLL_FAILURE}

			${If} $OCInitProductKey != ""
			${AndIf} $OCInitProductSecret != ""
				; Extract and load OpenCandy Network Client library
				File "/oname=$PLUGINSDIR\OCSetupHlp.dll" "${OC_OCSETUPHLP_FILE_PATH}"

				Push $1 ; Client session
				Push $2
				Push $3
				Push $4
				Push $5

				# Allocate and initialize memory for GUIDs
				System::Call /NOUNLOAD "*(&m${OC_GUID_CHARS} '') i .r2"
				System::Call /NOUNLOAD "*(&m${OC_GUID_CHARS} '') i .r3"
				System::Call /NOUNLOAD "*(&m${OC_GUID_CHARS} '') i .r4"
				StrCpy $5 ${OC_GUID_CHARS}
				ClearErrors
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy1(i, i, i, i, i, i)i (r2, ${OC_GUID_CHARS}, r3, ${OC_GUID_CHARS}, r4, r5).s ? c"
				Pop $0
				${If} ${Errors}                            ; System plug-in failed
				${OrIf} $0 == error                        ; API call failed
				${OrIf} $0 = ${OC_LOADOCDLL_FAILURE}       ; API returned failure
					StrCpy $0 ${OC_LOADOCDLL_FAILURE}
				${Else}
					; Store guid and memmap
					System::Call /NOUNLOAD "*$2(&m${OC_GUID_CHARS} .s)"
					Pop $OCAPIGuid
					System::Call /NOUNLOAD "*$3(&m${OC_GUID_CHARS} .s)"
					Pop $OCMemMapGuid
					System::Call /NOUNLOAD "*$4(&m${OC_GUID_CHARS} .s)"
					Pop $1
				${EndIf}

				; Free memory
				System::Free $4
				System::Free $3
				System::Free $2

				Pop $5
				Pop $4
				Pop $3
				Pop $2
				Pop $1
			${EndIf}

			${If} $0 = ${OC_LOADOCDLL_FAILURE}
				!insertmacro _OCSetNoCandy
			${EndIf}
			Pop $0
		${EndIf}
	${EndIf}
!macroend



;
; _OpenCandyAutoSelfDisable
; -------------------------
; This macro is internal to this helper script. Do not insert it in your own code.
;

!macro _OpenCandyAutoSelfDisable
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
		; OpenCandy is disabled during a silent installation
		${If} ${Silent}
			!insertmacro _OCSetNoCandy
		${Else}
			; OpenCandy may be explicitly disabled via command argument
			Push $0
			Push $1
			ClearErrors
			${GetParameters} $0
			${GetOptions} "$0" "/NOCANDY" $1
			${IfNot} ${Errors}
				!insertmacro _OCSetNoCandy
			${Else}
				ClearErrors
			${EndIf}
			Pop $1
			Pop $0
		${EndIf}
	${EndIf}
!macroend



;
; _ApplyDeferredSettings
; -------------------------------
; This macro is internal to this helper script. Do not insert it in your own code.
;

!macro _ApplyDeferredSettings
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
	${AndIf} $OCInitPerformInit == ${OC_INIT_PERFORM_BYPAGEORDER}
		; Apply background color settings for loading screen and offer screen
		${If} $OCUseDefaultColorBkGround == ${OC_NSIS_FALSE}
			!insertmacro OpenCandySetUseDefaultColorBkgrnd ${OC_NSIS_FALSE}
		${EndIf}
		${If} $OCCustomBrushColor != ""
			!insertmacro OpenCandySetCustomBrushColor $OCCustomBrushColor
		${EndIf}
		${If} $OCCustomImagePath != ""
			!insertmacro OpenCandyCustomImagePath $OCCustomImagePath
		${EndIf}
		!ifdef OC_REBOOT_PROTOTYPE
		${If} $OCSetPublisherMayReboot == ${OC_NSIS_TRUE}
			!insertmacro OCSetPublisherMayReboot ${OC_NSIS_TRUE}
		${EndIf}
		!endif
		; Inform the client if offers have already been disabled
		Push $0
		Push $r0
		${For} $0 1 $OCInitOffersRequested
			!insertmacro _OCArrayGetValue $OCArrayOfferIsEnabled $0 $r0
			${If} ${OC_NSIS_FALSE} == $r0 # OfferIsEnabled
				!insertmacro SetOCOfferEnabled $0 ${OC_NSIS_FALSE}
			${EndIf}
		${Next}
		Pop $r0
		Pop $0
	${EndIf}
!macroend



;
; OCSetAdvancedOptions
; --------------------
; This macro may only be called during the PreInit callback.
;
; Applies advanced options to OpenCandy. You should call this procedure only
; as explicitly directed by OpenCandy partner support.
;
; Parameters:
;
;   OC_ADVANCED_OPTIONS : Advanced options string
;

!macro OCSetAdvancedOptions OC_ADVANCED_OPTIONS
	${If} $OCAPIGuid != ""
	${AndIf} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized != ${OC_NSIS_TRUE}
		!ifdef NSIS_UNICODE
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy48(m, w)v ('$OCAPIGuid', '${OC_ADVANCED_OPTIONS}') ? c"
		!else
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy47(m, m)v ('$OCAPIGuid', '${OC_ADVANCED_OPTIONS}') ? c"
		!endif
	${EndIf}
!macroend



;
; OCApplyFilters
; --------------
; This procedure may only be called during the PreInit callback.
;
; Pass filter options to OpenCandy so that only recommendations meeting
; certain requirements will be made. You should call this procedure only
; as explicitly directed by OpenCandy partner support.
;
; Parameters:
;
;   OC_FILTER_LIST : A comma-separated list of filter keys
;
; Usage:
;
;   # Only show offers for candies
;   !insertmacro OCApplyFilters "candies"
;

!macro OCApplyFilters OC_FILTER_LIST
	${If} $OCAPIGuid != ""
	${AndIf} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized != ${OC_NSIS_TRUE}
		!ifdef NSIS_UNICODE
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy69(m,w)v ('$OCAPIGuid', '${OC_FILTER_LIST}') ? c"
		!else
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy68(m,m)v ('$OCAPIGuid', '${OC_FILTER_LIST}') ? c"
		!endif
	${EndIf}
!macroend



;
; OCApplyExclusions
; -----------------
; This procedure may only be called during the PreInit callback.
;
; Excludes certain recommendations from being made by OpenCandy. You should
; call this procedure only as explicitly directed by OpenCandy partner support.
;
; Parameters:
;
;   OC_EXCLUSION_LIST : A comma-separated list of exclusions
;
; Usage:
;
;   # Don't show recommendations for software that falls into the 'paint' category
;   !insertmacro OCApplyExclusions "cat_paint"
;

!macro OCApplyExclusions OC_EXCLUSION_LIST
	${If} $OCAPIGuid != ""
	${AndIf} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized != ${OC_NSIS_TRUE}
		!ifdef NSIS_UNICODE
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy71(m,w)v ('$OCAPIGuid', '${OC_EXCLUSION_LIST}') ? c"
		!else
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy70(m,m)v ('$OCAPIGuid', '${OC_EXCLUSION_LIST}') ? c"
		!endif
	${EndIf}
!macroend



;
; _OpenCandyAsyncInit
; -------------------
; This macro is internal to this helper script. Do not insert it in your own code.
; Instead, see OpenCandyAsyncInit.
;

!macro _OpenCandyAsyncInit
	Push $0
	Push $1
	Push $2
	Push $3
	Push $4
	Push $5
	Push $6

	; Initialize OpenCandy offers
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCAPIGuid != ""
	${AndIf} $OCHasBeenInitialized != ${OC_NSIS_TRUE}

		; Look for error conditions, warn publishers
		Push $0
		Push $1
		StrLen $0 $OCInitProductKey
		StrLen $1 $OCInitProductSecret
		${If}   $0 <> 32
		${OrIf} $1 <> 32
			!insertmacro _OpenCandyDevModeMsg "Warning: Product keys have unexpected number of characters." ${OC_NSIS_FALSE} 0
		${EndIf}
		Pop $1
		Pop $0

		; Pass command line to OpenCandy client
		Push $0
		${GetParameters} $0
		!ifdef NSIS_UNICODE
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy36(m, w)i ('$OCAPIGuid', r0).n ? c"
		!else
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy35(m, m)i ('$OCAPIGuid', r0).n ? c"
		!endif

		; Check if any of the command line arguments have disabled OpenCandy
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy32(m)i ('$OCAPIGuid').r0 ? c"
		${If} $0 = ${OC_CANDY_DISABLED}
			!insertmacro _OCSetNoCandy
		${EndIf}
		Pop $0

		; Pass publisher options to OpenCandy API and perform initialization
		${If} $OCNoCandy == ${OC_NSIS_FALSE}

			; Inform publisher installer that the SDK Initialize is about to be called and allow certain settings to be modified. (Optional feature)
			!ifdef OC_CALLBACKFN_PRE_INIT
				Call ${OC_CALLBACKFN_PRE_INIT}
			!endif

			; Pass legacy advanced options to client
			!ifdef OC_ADV_OPTIONS
				!insertmacro OCSetAdvancedOptions "${OC_ADV_OPTIONS}"
			!endif

			; Apply default exclusions
			!insertmacro OCApplyExclusions 'ocsdk_nsis'

			; Determine blocking time
			Push $0
			${If} $OCInitPerformInit == ${OC_INIT_PERFORM_NOW}
				StrCpy $0 ${OC_MAX_INIT_TIME_INIT_PERFORM_NOW}
			${Else}
				StrCpy $0 ${OC_MAX_INIT_TIME_INIT_PERFORM_BYPAGEORDER}
			${EndIf}

			!ifdef OC_REBOOT_PROTOTYPE
			; Apply reboot support options early incase reboot triggers during init blocking window
			${If} $OCSetPublisherMayReboot == ${OC_NSIS_TRUE}
				!insertmacro OCSetPublisherMayReboot ${OC_NSIS_TRUE}
			${EndIf}
			!endif

			; Initialize OpenCandy client
			!ifdef NSIS_UNICODE
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy6(m, w, w, w, i, i, i, i, i)i ('$OCAPIGuid', '$OCInitProductKey', '$OCInitProductSecret', $LANGUAGE, $OCInitOffersRequested, r0, $OCInitMode, ${OC_INIT_PROGRESSBAR_ENABLE}, ${OC_INIT_PROGRESSBAR_DELAY}).s ? c"
			!else
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy5(m, m, m, m, i, i, i, i, i)i ('$OCAPIGuid', '$OCInitProductKey', '$OCInitProductSecret', $LANGUAGE, $OCInitOffersRequested, r0, $OCInitMode, ${OC_INIT_PROGRESSBAR_ENABLE}, ${OC_INIT_PROGRESSBAR_DELAY}).s ? c"
			!endif
			Exch $0
			${If} $0 = ${OC_INIT_SUCCESS}
				StrCpy $OCHasBeenInitialized ${OC_NSIS_TRUE}
			${Else}
				!insertmacro _OCSetNoCandy
			${EndIf}
			Pop $0

			Pop $0
		${EndIf}
	${EndIf}

	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
!macroend



;
; OpenCandyAsyncInit
; ------------------
; Performs initialization of the OpenCandy DLL
; and checks for offers to present.
;
; Parameters:
;
;   Key            : Your product key for your offers (will be provided by OpenCandy)
;   Secret         : Your product secret for your offers (will be provided by OpenCandy)
;   InitModeOffer  : The operating mode for OpenCandy offer one. Pass OC_INIT_MODE_NORMAL
;                    for normal operation or OC_INIT_MODE_REMNANT if OpenCandy should not
;                    show offers. Do not use InitMode to handle /NOCANDY or silent installations,
;                    this is done automatically for you.
;   PerformInit    : When to perform initialization. Pass OC_INIT_PERFORM_NOW to extract and load
;                    the OpenCandy Network Client library and connect to the OpenCandy network
;                    immediately, or OC_INIT_PERFORM_BYPAGEORDER to defer these operations until
;                    the end user navigates to the OpenCandyLoadDLLPage and OpenCandyConnectPage
;                    placeholder pages, respectively.
; 	OffersRequested: The maximum number of offers you would like to display in your installer.
;
; Usage:
;
;   # Initialize OpenCandy, check for offers
;   #
;   # Note: If you use a language selection system,
;   #       e.g. MUI_LANGDLL_DISPLAY or calls to LangDLL, you must insert
;   #       this macro after the language selection code in order for
;   #       OpenCandy to detect the user-selected language.
;   !insertmacro OpenCandyAsyncInit 748ad6d80864338c9c03b664839d8161 dfb3a60d6bfdb55c50e1ef53249f1198 ${OC_INIT_MODE_NORMAL} ${OC_INIT_PERFORM_NOW} 4
;

!macro OpenCandyAsyncInit Key Secret InitModeOffer PerformInit OffersRequested
	!insertmacro _OpenCandyAPIInserted OpenCandyAsyncInit
	; Compile-time checks
	!if "${PerformInit}" == "${OC_INIT_PERFORM_NOW}"
	!else if "${PerformInit}" == "${OC_INIT_PERFORM_BYPAGEORDER}"
	!else
		!error "InitPerform must be either OC_INIT_PERFORM_NOW or OC_INIT_PERFORM_BYPAGEORDER."
	!endif
	!if "${Key}" == "${OC_SAMPLE_KEY}"
		!warning "Do not forget to change the sample key '${OC_SAMPLE_KEY}' to your company's product key before releasing this installer."
	!endif
	!if "${Secret}" == "${OC_SAMPLE_SECRET}"
		!warning "Do not forget to change the sample secret '${OC_SAMPLE_SECRET}' to your company's product secret before releasing this installer."
	!endif

	; Prepare OpenCandy NSIS layer
	!insertmacro _OpenCandyPrepareNSISAPI

	; Store init options
	StrCpy $OCInitProductKey "${Key}"
	StrCpy $OCInitProductSecret "${Secret}"
	StrCpy $OCInitMode ${InitModeOffer}
	StrCpy $OCInitPerformInit ${PerformInit}
	!insertmacro _OCClampInt ${OffersRequested} 0 ${OC_MAX_OFFERS}
	Exch $0
	StrCpy $OCInitOffersRequested $0
	Pop $0

	; Automatically disable OpenCandy under various circumstances
	!insertmacro _OpenCandyAutoSelfDisable
	${If} $OCInitPerformInit == ${OC_INIT_PERFORM_NOW}
		!insertmacro _OpenCandyLoadDLL
		!insertmacro _OpenCandyAsyncInit
	${EndIf}
!macroend



;
; GetOCOfferStatus
; ----------------
; Allows you to determine if an offer is currently available. This is
; done automatically for you before the offer screen is shown. Typically
; you do not need to call this function from your own code directly.
;
; The offer status is placed on the stack and may be one of:
; ${OC_OFFER_STATUS_CANOFFER_READY}    - An OpenCandy offer is available and ready to be shown
; ${OC_OFFER_STATUS_CANOFFER_NOTREADY} - An offer is available but is not yet ready to be shown
; ${OC_OFFER_STATUS_QUERYING_NOTREADY} - The remote API is still being queried for offers
; ${OC_OFFER_STATUS_NOOFFERSAVAILABLE} - No offers are available
;
; When using the macro you must indicate whether the information returned
; will be used to decide whether the OpenCandy offer screen will be shown, e.g.
; if the information may result in use of the SetOCOfferEnabled macro. This helps
; to optimize future OpenCandy SDKs for better performance with your product.
;
; Parameters:
;
;   OC_INSTANCE                 : The OpenCandy offer screen that is being configured (1 - 4)
;   OC_DETERMINES_OFFER_ENABLED : Does this call determine if offers will be shown? (OC_NSIS_TRUE or OC_NSIS_FALSE)
;
; Usage:
;
;   # Test if OpenCandy is ready to show offer one.
;   # Indicate the result is informative only and does not directly
;   # determine whether offers from OpenCandy are shown.
;   !insertmacro GetOCOfferStatus 1 ${OC_NSIS_FALSE}
;   Pop <result>
;

!macro GetOCOfferStatus OC_INSTANCE OC_DETERMINES_OFFER_ENABLED
	Push ${OC_DETERMINES_OFFER_ENABLED}
	Push ${OC_INSTANCE}
	Exch $0 ; Instance
	Exch
	Exch $1 ; Determines offers enabled
	Push $2 ; Result
	StrCpy $2 ${OC_OFFER_STATUS_NOOFFERSAVAILABLE}
	${If}    $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
	${AndIf} $0 > 0
	${AndIf} $0 <= $OCInitOffersRequested
		${If} $1 == ${OC_NSIS_TRUE}
			StrCpy $1 ${OC_STATUS_QUERY_DETERMINESOFFERENABLED}
		${Else}
			StrCpy $1 ${OC_STATUS_QUERY_GENERAL}
		${EndIf}
		IntOp $0 $0 - 1
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy31(m, i, i)i ('$OCAPIGuid', r1, r0).r2 ? c"
	${EndIf}
	StrCpy $0 $2
	Pop  $2
	Pop  $1
	Exch $0
!macroend



;
; _OpenCandyWasOCOfferAccepted
; ----------------------------
; This macro is internal to this helper script. Do not insert it in your own code.
;

!macro _OpenCandyWasOCOfferAccepted OC_INSTANCE
	Push ${OC_INSTANCE}
	Exch $0 ; Screen
	Push $1 ; Result
	StrCpy $1 ${OC_NSIS_FALSE}
	${If}    $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
	${AndIf} $0 > 0
	${AndIf} $0 <= $OCInitOffersRequested
		Push $r0
		Push $r1
		Push $r2
		!insertmacro _OCArrayGetValue $OCArrayShownOfferPage $0 $r0
		!insertmacro _OCArrayGetValue $OCArrayUseOfferPage   $0 $r1
		!insertmacro _OCArrayGetValue $OCArraySkipState      $0 $r2
		${If}    ${OC_NSIS_TRUE} == $r0 # ShownOfferPage
		${AndIf} ${OC_NSIS_TRUE} == $r1 # UseOfferPage
		${AndIf} ${OC_SKIPSTATE_NOTSKIPPED} == $r2 # SkipState
			IntOp $0 $0 - 1
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy10(m, i)i ('$OCAPIGuid', r0).r1 ? c"
			${If} $1 = ${OC_OFFER_CHOICE_ACCEPTED}
				StrCpy $1 ${OC_NSIS_TRUE}
			${Else}
				StrCpy $1 ${OC_NSIS_FALSE}
			${EndIf}
		${EndIf}
		Pop $r2
		Pop $r1
		Pop $r0
	${EndIf}
	StrCpy $0 $1
	Pop $1
	Exch $0
!macroend



;
; _OpenCandyWasOCOfferShown
; -------------------------
; This macro is internal to this helper script. Do not insert it in your own code.
;

!macro _OpenCandyWasOCOfferShown OC_INSTANCE
	Push ${OC_INSTANCE}
	Exch $0 ; Screen
	Push $r0
	StrCpy $r0 ${OC_NSIS_FALSE}
	${If}    $0 > 0
	${AndIf} $0 <= $OCInitOffersRequested
		!insertmacro _OCArrayGetValue $OCArrayShownOfferPage $0 $r0
	${EndIf}
	StrCpy $0 $r0
	Pop  $r0
	Exch $0
!macroend



;
; OpenCandyLoadDLLPage
; --------------------
; Inserts a placeholder page that is used to load the
; OpenCandy Network Client library after the .onInit callback
; function when the OC_INIT_PERFORM_BYPAGEORDER option is used.
;
; The placeholder page should be inserted as early as possible in
; the page list in order to maximize the likelihood that offers will
; be ready by the time the end user reaches the offer screen.
;
; Usage:
;
;   # Insert the OpenCandy connect page
;   !insertmacro OpenCandyLoadDLLPage
;

!macro OpenCandyLoadDLLPage
!ifndef _OpenCandyLoadDLLPage_Inserted
!define _OpenCandyLoadDLLPage_Inserted

	;
	; _OpenCandyLoadDLLPageStartFn
	; ----------------------------
	; Supports deferred connections to OpenCandy server.
	;
	; Do not call this function directly, it is a callback used
	; when you insert the OpenCandyConnectPage macro.
	;

	Function _OpenCandyLoadDLLPageStartFn
		${If} $OCInitPerformInit == ${OC_INIT_PERFORM_BYPAGEORDER}
			!insertmacro _OpenCandyLoadDLL
		${EndIf}
		Abort
	FunctionEnd

!endif # !ifndef _OpenCandyLoadDLLPage_Inserted

	!insertmacro _OpenCandyAPIInserted OpenCandyLoadDLLPage
	PageEx custom
		PageCallbacks _OpenCandyLoadDLLPageStartFn
	PageExEnd
!macroend



;
; OpenCandyConnectPage
; --------------------
; Inserts a placeholder page that is used to connect the OpenCandy
; Network Client to the OpenCandy Network after the .onInit function
; callback when the OC_INIT_PERFORM_BYPAGEORDER option is used.
;
; This placeholder page must be inserted after the page inserted by
; OpenCandyLoadDLLPage, and in most circumstances should follow
; immediately afterwards. Otherwise, it should be inserted as early as
; possible in the page list in order to maximize the likelihood that
; offers will be ready by the time the end user reaches the offer screen.
;
; Usage:
;
;   !insertmacro OpenCandyLoadDLLPage
;   # Insert the OpenCandy connect page
;   !insertmacro OpenCandyConnectPage
;

!macro OpenCandyConnectPage
!ifndef _OpenCandyConnectPage_Inserted
!define _OpenCandyConnectPage_Inserted

	;
	; _OpenCandyConnectPageStartFn
	; ----------------------------
	; Supports deferred connections to OpenCandy server.
	;
	; Do not call this function directly, it is a callback used
	; when you insert the OpenCandyConnectPage macro.
	;

	Function _OpenCandyConnectPageStartFn
		${If} $OCInitPerformInit == ${OC_INIT_PERFORM_BYPAGEORDER}
			; Initialize OpenCandy offers
			!insertmacro _OpenCandyAsyncInit
			!insertmacro _ApplyDeferredSettings
		${EndIf}
		Abort
	FunctionEnd

!endif # !ifndef _OpenCandyConnectPage_Inserted

	!insertmacro _OpenCandyAPIInserted OpenCandyConnectPage
	PageEx custom
		PageCallbacks _OpenCandyConnectPageStartFn
	PageExEnd
!macroend



;
; _OpenCandyPerformSkipNotify
; ---------------------------
; This macro is internal to this helper script. Do not insert it in your
; own code.
;
; Usage:
;
;   Push <skip notification>
;   Push <offer screen index>
;   Call _OpenCandyPerformSkipNotify
;

!macro _OpenCandyPerformSkipNotify
	; Inform publisher installer of skip control shown by OpenCandy
	!ifdef OC_CALLBACKFN_SKIP_NOTIFY
	Call ${OC_CALLBACKFN_SKIP_NOTIFY}
	!else
		Exch $0
		Pop $0
		Exch $0
		Pop $0
	!endif
!macroend



;
; _OpenCandyFindLoadingScreenInstance
; -----------------------------------
; This macro is internal to this helper script. Do not insert it in your
; own code.
;
; Usage:
;
;   Call _OpenCandyPerformSkipNotify
;   Pop <instance> # Instance that can support the loading screen, otherwise OC_LOADINGSCREEN_NOTACTIVE
;

!macro _OpenCandyFindLoadingScreenInstance
	; Check that at least one client instance can support a loading screen
	Push $0
	StrCpy $0 ${OC_LOADINGSCREEN_NOTACTIVE}
	${If} $OCHasBeenInitialized  == ${OC_NSIS_TRUE}
	${AndIf} $OCInitMode == ${OC_INIT_MODE_NORMAL}
		Push $1
		Push $r0
		Push $r1
		${For} $1 1 $OCInitOffersRequested
			!insertmacro _OCArrayGetValue $OCArraySkipState      $1 $r0
			!insertmacro _OCArrayGetValue $OCArrayOfferIsEnabled $1 $r1
			${If} ${OC_SKIPSTATE_NOTSKIPPED} == $r0 # SkipState
			${AndIf} ${OC_NSIS_TRUE} == $r1 # OfferIsEnabled
				StrCpy $0 $1
				${Break}
			${EndIf}
		${Next}
		Pop $r1
		Pop $r0
		Pop $1
	${EndIf}
	Exch $0
!macroend



;
; OpenCandyLoadingPage
; --------------------
; Inserts a placeholder page that is used to display a loading
; screen while the OpenCandy client is retrieving offers from
; the OpenCandy network. This placeholder page must be inserted after
; the page inserted by OpenCandyConnectPage.
;
; The placeholder page should generally be inserted immediately before
; the OpenCandy offer screen to minimize both the likelihood that it
; will be displayed and the display duration.
;
; Usage:
;
;   !insertmacro OpenCandyLoadDLLPage
;   !insertmacro OpenCandyConnectPage
;   # ...
;   # Insert the OpenCandy loading page
;   !insertmacro OpenCandyLoadingPage
;

!macro OpenCandyLoadingPage
!ifndef _OpenCandyLoadingPage_Inserted
!define _OpenCandyLoadingPage_Inserted

	;
	; _OpenCandyShowLoadingScreenCallback
	; -----------------------------------
	; This macro is internal to this helper script. Do not
	; insert it in your own code. Instead see OpenCandyLoadingPage.
	;

	Function _OpenCandyShowLoadingScreenCallback
		; Kill the timer that triggers this function
		${NSD_KillTimer} _OpenCandyShowLoadingScreenCallback

		${If} $OCAPIGuid != ""
			; Attach the loading screen, passing publisher options, and wait for blocking call to end.
			Push $0
			${If} $OCInitPerformInit == ${OC_INIT_PERFORM_NOW}
				StrCpy $0 ${OC_MAX_LOADING_TIME_INIT_PERFORM_NOW}
			${Else}
				StrCpy $0 ${OC_MAX_LOADING_TIME_INIT_PERFORM_BYPAGEORDER}
			${EndIf}
			!insertmacro  _OCMinInt ${OC_MAX_LOADING_OFFER_COUNT} $OCInitOffersRequested
			Exch $1
			!ifdef NSIS_UNICODE
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy52(m, i, i, w, w, i, i)v ('$OCAPIGuid', r0, $OCLoadingScreenHWND, '${OC_LOADING_SCREEN_MESSAGE}', '${OC_LOADING_SCREEN_FONTFACE}', ${OC_LOADING_SCREEN_FONTSIZE}, r1) ? c"
			!else
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy51(m, i, i, m, m, i, i)v ('$OCAPIGuid', r0, $OCLoadingScreenHWND, '${OC_LOADING_SCREEN_MESSAGE}', '${OC_LOADING_SCREEN_FONTFACE}', ${OC_LOADING_SCREEN_FONTSIZE}, r1) ? c"
			!endif
			Pop $1
			StrCpy $OCLoadingScreenActivity ${OC_LOADINGSCREEN_NOTACTIVE}
			Pop $0
		${EndIf}

		; Re-enable UI buttons
		Push $0
		Push $1
		${For} $0 1 3 ; 1 = Next, 2 = Cancel, 3 = Back
			GetDlgItem $1 $HWNDPARENT $0
			EnableWindow $1 1
		${Next}
		Pop $1
		Pop $0

		; Click "Next" button automatically to leave loading page
		System::Call "User32.dll::SetActiveWindow(i)i ($HWNDPARENT).n"
		Push $0
		GetDlgItem $0 $HWNDPARENT 1
		SendMessage $0 ${BM_CLICK} 0 0 /TIMEOUT=${OC_SENDMSG_TIMEOUT}
		Pop $0
	FunctionEnd



	;
	; _OpenCandyLoadingPageStartFn
	; ----------------------------
	; This macro is internal to this helper script. Do not
	; insert it in your own code. Instead see OpenCandyLoadingPage.
	;

	Function _OpenCandyLoadingPageStartFn
		${If} $OCNoCandy != ${OC_NSIS_FALSE}
		${OrIf} $OCHasBeenInitialized != ${OC_NSIS_TRUE}
		${OrIf} $OCHasShownLoadingScreen == ${OC_NSIS_TRUE}
		${OrIf} $OCInitOffersRequested < 1
			Abort
		${EndIf}

		; Prevent loading screen being shown more than once
		StrCpy $OCHasShownLoadingScreen ${OC_NSIS_TRUE}

		; Check that at least one client instance can support a loading screen
		!insertmacro _OpenCandyFindLoadingScreenInstance
		Exch $0
		${If} $0 == ${OC_LOADINGSCREEN_NOTACTIVE}
			Pop $0
			Abort
		${EndIf}
		Pop $0

		; Check if the user already skipped all pages
		Push 1
		!insertmacro _OpenCandyPerformSkipQuery

		; Select an client instance that can show the loading screen
		!insertmacro _OpenCandyFindLoadingScreenInstance
		Pop $OCLoadingScreenActivity
		${If} $OCLoadingScreenActivity == ${OC_LOADINGSCREEN_NOTACTIVE}
			Abort
		${EndIf}

		; Create placeholder page
		nsDialogs::Create /NOUNLOAD 1018
		Pop $OCLoadingScreenHWND
		${If} $OCLoadingScreenHWND == error
			Abort
		${EndIf}

		; Set the page caption and description
		!insertmacro ${OC_CAPTION_MACRO_NAME}  "${OC_LOADING_SCREEN_CAPTION}" "${OC_LOADING_SCREEN_DESCRIPTION}"

		; Disable UI buttons
		Push $0
		Push $1
		${For} $0 1 3 ; 1 = Next, 2 = Cancel, 3 = Back
			!ifdef OC_LOADING_SCREEN_ENABLECANCEL
				${If} $0 <> 2
			!endif
			GetDlgItem $1 $HWNDPARENT $0
			EnableWindow $1 0
			!ifdef OC_LOADING_SCREEN_ENABLECANCEL
				${EndIf}
			!endif
		${Next}
		Pop $1
		Pop $0

		; Use a timer callback to attach the loading screen
		${NSD_CreateTimer} _OpenCandyShowLoadingScreenCallback 1

		; Show the placeholder page
		nsDialogs::Show
	FunctionEnd



	;
	; _OpenCandyLoadingPageLeaveFn
	; ----------------------------
	; This macro is internal to this helper script. Do not
	; insert it in your own code. Instead see OpenCandyLoadingPage.
	;

	Function _OpenCandyLoadingPageLeaveFn
		; Prevent forward navigation while loading screen is displayed
		${If} $OCLoadingScreenActivity != ${OC_LOADINGSCREEN_NOTACTIVE}
			Abort
		${EndIf}
	FunctionEnd

!endif # !ifndef _OpenCandyLoadingPage_Inserted

	PageEx custom
		PageCallbacks _OpenCandyLoadingPageStartFn _OpenCandyLoadingPageLeaveFn
	PageExEnd
!macroend



;
; _OpenCandyShowSkipControl
; -------------------------
;
; This macro is internal to this helper script. Do not insert it in your own code.
;
; Usage:
;
;   Push <instance>
;   !insertmacro _OpenCandyShowSkipControl
;

!macro _OpenCandyShowSkipControl
	Exch $0 ; Screen
	${If}    $0 > 0
	${AndIf} $0 <= $OCInitOffersRequested
		Push $0
		!insertmacro _OpenCandyGetSkipFmt
		Exch $1
		${If} $1 <> ${OC_SKIPFMT_NOTSHOWN}
			Push $2
			Push $3
			Push $4

			; Next button HWND
			GetDlgItem $2 $HWNDPARENT 1
			${If} $1 == ${OC_SKIPFMT_BUTTON}
				; Skip control must be a button
				; Use Back button control for skip all button placement
				GetDlgItem $3 $HWNDPARENT 2
				; Skip control style and alignment
				StrCpy $4 ${OC_CTRL_SKIP_BUTTON_ALIGNMENT}
				IntOp $4 $4 | ${OC_USE_BUTTON_CONTROL}
				; Call method to show Skip control
				!ifdef NSIS_UNICODE
					System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy62(m, i, i, i, i, i, i, w, w, i, i, w, w, w)v ('$OCAPIGuid', r3, r4, ${OC_CTRL_SKIP_BUTTON_OFFSET_X}, ${OC_CTRL_SKIP_BUTTON_OFFSET_Y}, r2, 0, '', '${OC_CTRL_SKIP_BUTTON_FONT_NAME}', ${OC_CTRL_SKIP_BUTTON_FONT_SIZE}, 0, '${OC_CTRL_SKIP_BUTTON_TEXTCOLOR}', '${OC_CTRL_SKIP_BUTTON_BGCOLOR}', '${OC_CTRL_SKIP_BUTTON_MSG_CUSTOM}') ? c"
				!else
					System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy56(m, i, i, i, i, i, i, m, m, i, i, m, m, m)v ('$OCAPIGuid', r3, r4, ${OC_CTRL_SKIP_BUTTON_OFFSET_X}, ${OC_CTRL_SKIP_BUTTON_OFFSET_Y}, r2, 0, '', '${OC_CTRL_SKIP_BUTTON_FONT_NAME}', ${OC_CTRL_SKIP_BUTTON_FONT_SIZE}, 0, '${OC_CTRL_SKIP_BUTTON_TEXTCOLOR}', '${OC_CTRL_SKIP_BUTTON_BGCOLOR}', '${OC_CTRL_SKIP_BUTTON_MSG_CUSTOM}') ? c"
				!endif
			${Else}
				; Skip control will be active text
				; Hide BrandingText
				GetDlgItem $3 $HWNDPARENT 1028
				ShowWindow $3 ${SW_HIDE}
				GetDlgItem $3 $HWNDPARENT 1256
				ShowWindow $3 ${SW_HIDE}
				; Hide GroupBox
				GetDlgItem $3 $HWNDPARENT 1035
				ShowWindow $3 ${SW_HIDE}
				; Text control to use for skip all link placement
				GetDlgItem $3 $HWNDPARENT 1256
				; Skip control style and alignment
				StrCpy $4 ${OC_CTRL_SKIP_ATEXT_ALIGNMENT}
				; Call method to show Skip control
				!ifdef NSIS_UNICODE
					System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy62(m, i, i, i, i, i, i, w, w, i, i, w, w, w)v ('$OCAPIGuid', r3, r4, ${OC_CTRL_SKIP_ATEXT_OFFSET_X}, ${OC_CTRL_SKIP_ATEXT_OFFSET_Y}, r2, ${OC_CTRL_SKIP_ATEXT_LINE_ENABLE}, '${OC_CTRL_SKIP_ATEXT_LINE_FGCOLOR}', '${OC_CTRL_SKIP_ATEXT_FONT_NAME}', ${OC_CTRL_SKIP_ATEXT_FONT_SIZE}, ${OC_CTRL_SKIP_ATEXT_UNDERLINE_ENABLE}, '${OC_CTRL_SKIP_ATEXT_TEXTCOLOR}', '${OC_CTRL_SKIP_ATEXT_BGCOLOR}', '${OC_CTRL_SKIP_ATEXT_MSG_CUSTOM}') ? c"
				!else
					System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy56(m, i, i, i, i, i, i, m, m, i, i, m, m, m)v ('$OCAPIGuid', r3, r4, ${OC_CTRL_SKIP_ATEXT_OFFSET_X}, ${OC_CTRL_SKIP_ATEXT_OFFSET_Y}, r2, ${OC_CTRL_SKIP_ATEXT_LINE_ENABLE}, '${OC_CTRL_SKIP_ATEXT_LINE_FGCOLOR}', '${OC_CTRL_SKIP_ATEXT_FONT_NAME}', ${OC_CTRL_SKIP_ATEXT_FONT_SIZE}, ${OC_CTRL_SKIP_ATEXT_UNDERLINE_ENABLE}, '${OC_CTRL_SKIP_ATEXT_TEXTCOLOR}', '${OC_CTRL_SKIP_ATEXT_BGCOLOR}', '${OC_CTRL_SKIP_ATEXT_MSG_CUSTOM}') ? c"
				!endif
			${Endif}
			StrCpy $OCSkipControlAttached ${OC_NSIS_TRUE}
			Pop $4
			Pop $3
			Pop $2
		${EndIf}
		Pop $1
	${EndIf}
	Pop $0
!macroend



;
; _OpenCandyHideSkipControl
; -------------------------
;
; This macro is internal to this helper script. Do not insert it in your own code.
;
; Usage:
;
;   !insertmacro _OpenCandyHideSkipControl
;

!macro _OpenCandyHideSkipControl
	${If} $OCSkipControlAttached == ${OC_NSIS_TRUE}
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy57(m)v ('$OCAPIGuid') ? c"
		StrCpy $OCSkipControlAttached ${OC_NSIS_FALSE}

		Push $0
		; Show BrandingText
		GetDlgItem $0 $HWNDPARENT 1028
		ShowWindow $0 ${SW_SHOW}
		GetDlgItem $0 $HWNDPARENT 1256
		ShowWindow $0 ${SW_SHOW}
		; Show GroupBox
		GetDlgItem $0 $HWNDPARENT 1035
		ShowWindow $0 ${SW_SHOW}
		Pop $0
	${EndIf}
!macroend



;
; _OpenCandyOfferPageFns
; ----------------------
; This macro is internal to this helper script. Do not insert it in your own code.
; Instead, see OpenCandyOfferPage
;

!macro _OpenCandyOfferPageFns
	!ifndef _OpenCandyOfferPageFns
	!define _OpenCandyOfferPageFns

	;
	; _OCOfferScreenErrorCallbackFn
	; -----------------------------
	; Callback to skip the offer page and disables offers,
	; e.g. in event displaying offer screen fails.
	;
	; Do not call this function directly, it is a callback used
	; when you insert the OpenCandyOfferPage macro.
	;

	Function _OCOfferScreenErrorCallbackFn
		; Kill the timer that triggers this function
		${NSD_KillTimer} _OCOfferScreenErrorCallbackFn

		; Hide Skip control if applicable
		!insertmacro _OpenCandyHideSkipControl

		; Hide the Decline control
		Push $0
		IntOp $0 $OCActiveOfferPage - 1
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy12(m, i)i ('$OCAPIGuid', r0).n ? c"
		Pop $0

		; Click "Next" button automatically to leave offer page
		System::Call "User32.dll::SetActiveWindow(i)i ($HWNDPARENT).n"
		Push $0
		GetDlgItem $0 $HWNDPARENT 1
		SendMessage $0 ${BM_CLICK} 0 0 /TIMEOUT=${OC_SENDMSG_TIMEOUT}
		Pop $0
	FunctionEnd



	;
	; _OpenCandyOfferPageBackFn
	; -------------------------
	; Callback to handle Back button on OpenCandy offer page
	;
	; Do not call this function directly, it is a callback used
	; when you insert the OpenCandyOfferPage macro.
	;

	Function _OpenCandyOfferPageBackFn
		; Update skip shown state
		${If} $OCSkipControlAttached == ${OC_NSIS_TRUE}
			Push ${OC_SKIPNOTIFICATION_SHOWN_NOTACTIVATED}
			Push $OCActiveOfferPage
			!insertmacro _OpenCandyPerformSkipNotify
		${EndIf}
		; Detach offer screen if previously attached
		Push $r0
		!insertmacro _OCArrayGetValue $OCArrayOfferAttached $OCActiveOfferPage $r0
		${If} ${OC_NSIS_TRUE} == $r0 # OfferAttached
			Push $1
			IntOp $1 $OCActiveOfferPage - 1
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy12(m)i ('$OCAPIGuid', r1).n ? c"
			Pop $1
			!insertmacro _OCArraySetValue $OCArrayOfferAttached $OCActiveOfferPage ${OC_NSIS_FALSE}
		${EndIf}
		Pop $r0
		; Remove skip controls
		!insertmacro _OpenCandyHideSkipControl
	FunctionEnd



	;
	; _OpenCandyOfferPageStartFn
	; --------------------------
	; Decides if there is an offer to show and if so sets up
	; the offer page for NSIS.
	;
	; Do not call this function directly, it is a callback used
	; when you insert the OpenCandyOfferPage macro.
	;
	; Usage:
	;   Call _OpenCandyOfferPageStartFn
	;   Pop <abort flag> # OC_NSIS_TRUE if the callee should execute an Abort instruction
	;

	Function _OpenCandyOfferPageStartFn
		Push $0 # Abort flag
		StrCpy $0 ${OC_NSIS_FALSE}

		# Check that it is valid to attempt to show this page
		Push $r0
		!insertmacro _OCArrayGetValue $OCArrayOfferIsEnabled $OCActiveOfferPage $r0
		${If} $OCNoCandy != ${OC_NSIS_FALSE}
		${OrIf} $OCHasBeenInitialized != ${OC_NSIS_TRUE}
		${OrIf} $OCActiveOfferPage > $OCInitOffersRequested
		${OrIf} ${OC_NSIS_FALSE} == $r0 # OfferIsEnabled
			!insertmacro _OCArraySetValue $OCArrayUseOfferPage $OCActiveOfferPage ${OC_NSIS_FALSE}
			StrCpy $0 ${OC_NSIS_TRUE}  # Set abort flag
		${EndIf}
		Pop $r0
		${If} $0 == ${OC_NSIS_TRUE}
			Goto LblExitFn
		${EndIf}

		; Test if an offer is ready
		Push $r0
		!insertmacro _OCArrayGetValue $OCArrayHasReachedOfferPage $OCActiveOfferPage $r0
		${If} ${OC_NSIS_FALSE} == $r0 # HasReachedOfferPage
			Push $1
			IntOp $1 $OCActiveOfferPage - 1
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy31(m, i, i)i ('$OCAPIGuid', ${OC_STATUS_QUERY_DETERMINESOFFERENABLED}, r1).s ? c"
			Exch $2
			${If} $2 = ${OC_OFFER_STATUS_CANOFFER_READY}
				!insertmacro _OCArraySetValue $OCArrayUseOfferPage $OCActiveOfferPage ${OC_NSIS_TRUE}
			${Else}
				!insertmacro _OCArraySetValue $OCArrayUseOfferPage $OCActiveOfferPage ${OC_NSIS_FALSE}
			${EndIf}
			Pop $2
			Pop $1
			!insertmacro _OCArraySetValue $OCArrayHasReachedOfferPage $OCActiveOfferPage ${OC_NSIS_TRUE}
		${EndIf}
		Pop $r0

		Push $r0
		!insertmacro _OCArrayGetValue $OCArraySkipState $OCActiveOfferPage $r0
		${If} ${OC_SKIPSTATE_NOTSKIPPED} == $r0 # SkipState
			; Get active ad policy settings
			!ifdef OC_CALLBACKFN_ADPOLICY_QUERY
				Push $OCActiveOfferPage
				Call ${OC_CALLBACKFN_ADPOLICY_QUERY}
			!endif
			; Check to see if any external Skip event has taken place
			Push $OCActiveOfferPage
			!insertmacro _OpenCandyPerformSkipQuery
		${EndIf}
		; Handle any prior Skip events affecting this screen
		; Skip state may have been updated during callback
		!insertmacro _OCArrayGetValue $OCArraySkipState $OCActiveOfferPage $r0
		${If} ${OC_SKIPSTATE_NOTSKIPPED} !=  $r0 # SkipState
			!insertmacro _OpenCandyHandleSkip $OCActiveOfferPage $OCActiveOfferPage
		${EndIf}
		Pop $r0

		; Set up the offer
		Push $r0
		!insertmacro _OCArrayGetValue $OCArrayUseOfferPage $OCActiveOfferPage $r0
		${If} ${OC_NSIS_TRUE} != $r0 # UseOfferPage
			Pop $r0
		${Else}
			Pop $r0

			; Create and show offer page
			nsDialogs::Create /NOUNLOAD 1018
			Exch $1
			${If} $1 == error
				; Disable this offer because of error in nsDialogs
				!insertmacro _OCArraySetValue $OCArrayUseOfferPage $OCActiveOfferPage ${OC_NSIS_FALSE}
			${Else}
				; Get caption and description strings for the offer screen
				!ifdef NSIS_UNICODE
					!define OC_TMP_STRTYPE w
				!else
					!define OC_TMP_STRTYPE m
				!endif
				Push $1
				Push $2
				Push $3
				Push $4
				StrCpy $1 " " ; Title
				StrCpy $2 " " ; Description
				System::Call /NOUNLOAD "*(&${OC_TMP_STRTYPE}${OC_STR_CHARS} '') i .r3" ; $3 points to OC_STR_CHARS chars of initialized memory
				System::Call /NOUNLOAD "*(&${OC_TMP_STRTYPE}${OC_STR_CHARS} '') i .r4" ; $4 points to OC_STR_CHARS chars of initialized memory
				; Check if we need to show Advertisement text
				Push $OCActiveOfferPage
				!insertmacro _OCBannerAdTextIsRequired
				Exch $5
				${If} $5 == ${OC_NSIS_TRUE}
					StrCpy $5 ${OC_OFFER_BANNER_USEADTEXT_ON}
				${Else}
					StrCpy $5 ${OC_OFFER_BANNER_USEADTEXT_OFF}
				${EndIf}
				Push $6
				IntOp $6 $OCActiveOfferPage - 1
				; Fetch available banner text
				!ifdef NSIS_UNICODE
					System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy8(m, m, i, i, i, i)i ('$OCAPIGuid', '$OCMemMapGuid', r3, r4, r5, r6).s ? c"
				!else
					System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy7(m, m, i, i, i, i)i ('$OCAPIGuid', '$OCMemMapGuid', r3, r4, r5, r6).s ? c"
				!endif
				Pop $5
				; Determine which banner strings were available and extract them
				${If} $5 = ${OC_OFFER_BANNER_FOUNDBOTH}
					System::Call /NOUNLOAD "*$3(&${OC_TMP_STRTYPE}${OC_STR_CHARS} .s)"
					Pop $1
					System::Call /NOUNLOAD "*$4(&${OC_TMP_STRTYPE}${OC_STR_CHARS} .s)"
					Pop $2
				${ElseIf} $5 = ${OC_OFFER_BANNER_FOUNDTITLE}
					System::Call /NOUNLOAD "*$3(&${OC_TMP_STRTYPE}${OC_STR_CHARS} .s)"
					Pop $1
				${ElseIf} $5 = ${OC_OFFER_BANNER_FOUNDDESCRIPTION}
					System::Call /NOUNLOAD "*$4(&${OC_TMP_STRTYPE}${OC_STR_CHARS} .s)"
					Pop $2
				${EndIf}
				Pop $6
				Pop $5
				System::Free $4
				System::Free $3
				Pop $4
				Pop $3
				; Set the page caption and description
				!insertmacro ${OC_CAPTION_MACRO_NAME} $1 $2
				Pop $2
				Pop $1
				!undef OC_TMP_STRTYPE

				; Adjust the window
				Push $2
				IntOp $2 $OCActiveOfferPage - 1
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy15(m, i, i, i, i, i, i, i, i, i)i ('$OCAPIGuid', r1, ${OC_WND_OFFSET_X}, ${OC_WND_OFFSET_Y}, ${OC_WND_WIDTH}, ${OC_WND_HEIGHT}, ${OC_WND_ADJUST_MODE}, ${OC_WND_ADJUST_PARAM1}, ${OC_WND_ADJUST_PARAM2}, r2).n ? c"
				Pop $2

				; Check if a Decline control is required
				Push $OCActiveOfferPage
				!insertmacro _OCDeclineButtonIsRequired
				Exch $1
				${If} $1 == ${OC_NSIS_TRUE}
					; Prepare Decline control
					Push $2
					GetDlgItem $1 $HWNDPARENT 3
					GetDlgItem $2 $HWNDPARENT 1
					System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy60(m, i, i, i, i, i, m, i)v ('$OCAPIGuid', r1, ${OC_CTRL_DECLINE_ALIGNMENT}, ${OC_CTRL_DECLINE_OFFSET_X}, ${OC_CTRL_DECLINE_OFFSET_Y}, r2, '${OC_CTRL_DECLINE_FONT_NAME}', ${OC_CTRL_DECLINE_FONT_SIZE}) ? c"
					Pop $2
				${EndIf}
				Pop $1

				; Check if OpenCandy should display a Skip control
				Push $OCActiveOfferPage
				!insertmacro _OpenCandyShowSkipControl

				; Attach the OpenCandy offer screen
				Push $2
				IntOp $2 $OCActiveOfferPage - 1
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy9(m, i, i)i ('$OCAPIGuid', r1, r2).s ? c"
				Exch $2
				${If} $2 <> ${OC_OFFER_RUN_DIALOG_FAILURE}
					!insertmacro _OCArraySetValue $OCArrayOfferAttached  $OCActiveOfferPage ${OC_NSIS_TRUE}
					!insertmacro _OCArraySetValue $OCArrayShownOfferPage $OCActiveOfferPage ${OC_NSIS_TRUE}
					${If} $OCInstanceDisplayedFirst = ${OC_INSTANCE_DISPLAYEDFIRST_NOTSET}
						StrCpy $OCInstanceDisplayedFirst $OCActiveOfferPage
					${EndIf}
				${Else}
					; Disable all offers because of errors attaching offer screens
					Push $0
					${For} $0 1 $OCInitOffersRequested
						!insertmacro _OCArraySetValue $OCArrayUseOfferPage $0 ${OC_NSIS_FALSE}
						!insertmacro SetOCOfferEnabled $0 ${OC_NSIS_FALSE}
					${Next}
					Pop $0
					; If nsDialogs::Create has succeeded nsDialogs::Show must be called.
					; Use a callback to disable the offer and skip the page.
					${NSD_CreateTimer} _OCOfferScreenErrorCallbackFn 1
				${EndIf}
				Pop $2
				Pop $2

				; Add Back button handler
				Push $1
				GetFunctionAddress $1 _OpenCandyOfferPageBackFn
				nsDialogs::OnBack $1
				Pop $1
				nsDialogs::Show
			${EndIf}
			Pop $1
		${EndIf}

		# Check the page displayed correctly
		Push $r0
		!insertmacro _OCArrayGetValue $OCArrayUseOfferPage $OCActiveOfferPage $r0
		${If} ${OC_NSIS_TRUE} != $r0 # UseOfferPage
			StrCpy $0 ${OC_NSIS_TRUE}  # Set abort flag
		${EndIf}
		Pop $r0

		LblExitFn:
		Exch $0
	FunctionEnd



	;
	; _OpenCandyOfferPageLeaveFn
	; --------------------------
	; Decides if it is ok for the end user to leave the offer
	; page and continue with setup.
	;
	; Do not call this function directly, it is a callback used
	; when you insert the OpenCandyOfferPage macro.
	;

	Function _OpenCandyOfferPageLeaveFn
		Push $0 # Abort flag
		StrCpy $0 ${OC_NSIS_FALSE}

		# Check that it is valid to process this page
		Push $r0
		!insertmacro _OCArrayGetValue $OCArrayOfferIsEnabled $OCActiveOfferPage $r0
		${If} $OCNoCandy != ${OC_NSIS_FALSE}
		${OrIf} $OCHasBeenInitialized != ${OC_NSIS_TRUE}
		${OrIf} ${OC_NSIS_FALSE} == $r0 # OfferIsEnabled
			StrCpy $0 ${OC_NSIS_TRUE}  # Set abort flag
		${EndIf}
		Pop $r0
		${If} $0 == ${OC_NSIS_TRUE}
			Goto LblExitFn
		${EndIf}

		; Test if Skip control was shown and activated
		${If} $OCSkipControlAttached == ${OC_NSIS_TRUE}
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy58(m)i ('$OCAPIGuid').s ? c"
			Exch $1
			${If} $1 = ${OC_CONTROL_SKIP_USED}
				!insertmacro _OpenCandyHandleSkip $OCActiveOfferPage $OCActiveOfferPage
			${EndIf}
			Pop $1
		${EndIf}

		Push $r0
		!insertmacro _OCArrayGetValue $OCArraySkipState $OCActiveOfferPage $r0
		${If} ${OC_SKIPSTATE_NOTSKIPPED} == $r0 # SkipState
			; Test if Decline control was shown and activated
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy61(m)i ('$OCAPIGuid').s ? c"
			Exch $1
			${If} $1 = ${OC_CONTROL_DECLINE_USED}
				!insertmacro _OCArraySetValue $OCArrayUseOfferPage $OCActiveOfferPage ${OC_NSIS_FALSE}
				Push $2
				IntOp $2 $OCActiveOfferPage - 1
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy59(m, i, i)v ('$OCAPIGuid', ${OC_SKIPPED_OPENCANDYDECLINE}, r2) ? c"
				Pop $2
			${Else}
				; Make sure the user made a selection before leaving the offer screen
				Push $2
				IntOp $2 $OCActiveOfferPage - 1
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy34(m, m, i)i ('$OCAPIGuid', '$OCMemMapGuid', r2).r1 ? c"
				Pop $2
				${If} $1 = ${OC_OFFER_LEAVEPAGE_DISALLOWED} ; User must choose an option before proceeding
					StrCpy $0 ${OC_NSIS_TRUE}  # Set abort flag
				${EndIf}
			${EndIf}
			Pop $1
		${EndIf}
		Pop $r0
		${If} $0 == ${OC_NSIS_TRUE}
			Goto LblExitFn
		${EndIf}

		; Notify the publisher installer if Skip control was displayed or activated
		${If} $OCSkipControlAttached == ${OC_NSIS_TRUE}
			Push $r0
			!insertmacro _OCArrayGetValue $OCArraySkipState $OCActiveOfferPage $r0
			${If} ${OC_SKIPSTATE_NOTSKIPPED} == $r0 # SkipState
				Pop $r0
				Push ${OC_SKIPNOTIFICATION_SHOWN_NOTACTIVATED}
			${Else}
				Pop $r0
				Push ${OC_SKIPNOTIFICATION_SHOWN_ACTIVATED}
			${EndIf}
			Push $OCActiveOfferPage
			!insertmacro _OpenCandyPerformSkipNotify
		${EndIf}

		; Detach offer screen
		Push $r0
		!insertmacro _OCArrayGetValue $OCArrayOfferAttached $OCActiveOfferPage $r0
		${If} ${OC_NSIS_TRUE} == $r0 # OfferAttached
			Push $1
			IntOp $1 $OCActiveOfferPage - 1
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy12(m, i)i ('$OCAPIGuid', r1).n ? c"
			Pop $1
			!insertmacro _OCArraySetValue $OCArrayOfferAttached $OCActiveOfferPage ${OC_NSIS_FALSE}
		${EndIf}
		Pop $r0

		; Hide Skip control if applicable
		!insertmacro _OpenCandyHideSkipControl

		; Provide an opportunity for publisher to query any policies in effect
		!ifdef OC_CALLBACKFN_ADPOLICY_NOTIFY
			Push $OCActiveOfferPage
			Call ${OC_CALLBACKFN_ADPOLICY_NOTIFY}
		!endif

		LblExitFn:
		${If} $0 == ${OC_NSIS_TRUE}
			Pop $0
			Abort
		${EndIf}
		Pop $0
		StrCpy $OCActiveOfferPage ${OC_OFFERPAGE_NOTACTIVE}
	FunctionEnd

	!endif # !ifndef _OpenCandyOfferPageFns
!macroend



!macro _OpenCandyOfferPageN OC_INSTANCE
!if ${OC_INSTANCE} <= ${OC_MAX_OFFERS}
	!insertmacro _OpenCandyCheckInstance ${OC_INSTANCE}
	!ifdef _OpenCandyOfferPage_Inserted${OC_INSTANCE}
		!warning "Attempted to insert OpenCandy offer page ${OC_INSTANCE} more than once."
	!else
		!define _OpenCandyOfferPage_Inserted${OC_INSTANCE}
		!insertmacro _OpenCandyOfferPageFns

		Function _OCStartOfferPageNFn${OC_INSTANCE}
			StrCpy $OCActiveOfferPage ${OC_INSTANCE}
			Call _OpenCandyOfferPageStartFn
			Exch $0
			${If} $0 == ${OC_NSIS_TRUE}
				Pop $0
				StrCpy $OCActiveOfferPage ${OC_OFFERPAGE_NOTACTIVE}
				Abort
			${EndIf}
			Pop $0
		FunctionEnd

	!endif # !ifndef _OpenCandyOfferPage_Inserted${OC_INSTANCE}
!endif # OC_MAX_OFFERS check

	!insertmacro _OpenCandyAPIInserted OpenCandyOfferPage${OC_INSTANCE}
	PageEx custom
		PageCallbacks _OCStartOfferPageNFn${OC_INSTANCE} _OpenCandyOfferPageLeaveFn
	PageExEnd
!macroend



;
; OpenCandyOfferPage
; ------------------
; Insert the OpenCandy offer pages. The offer pages are displayed if
; a valid offer was found for the specific end user system in the time
; since the OpenCandy Network Client connected to the OpenCandy servers.
;
; The offer pages should generally be inserted as late in the installation
; sequence as possible, just before installation begins. This helps to
; maximize the likelihood that offers will be ready.
;
; Parameters:
;
;   PAGENUM : The number of the OpenCandy offer page to be inserted
;
; Usage:
;
;   !insertmacro OpenCandyLoadDLLPage
;   !insertmacro OpenCandyConnectPage
;   # ...
;   !insertmacro OpenCandyLoadingPage
;   # Insert the OpenCandy offer pages
;   !insertmacro OpenCandyOfferPage 1
;   !insertmacro OpenCandyOfferPage 2
;   !insertmacro OpenCandyOfferPage 3
;   !insertmacro OpenCandyOfferPage 4
;

!macro OpenCandyOfferPage PAGENUM
	!insertmacro _OpenCandyOfferPageN ${PAGENUM}
!macroend



;
; OpenCandyInsertAllOfferPages
; ----------------------------
; Insert all OpenCandy offer pages. The offer pages are displayed if
; a valid offer was found for the specific end user system in the time
; since the OpenCandy Network Client connected to the OpenCandy servers.
;
; The offer pages should generally be inserted as late in the installation
; sequence as possible, just before installation begins. This helps to
; maximize the likelihood that offers will be ready.
;
; Usage:
;
;   !insertmacro OpenCandyLoadDLLPage
;   !insertmacro OpenCandyConnectPage
;   # ...
;   !insertmacro OpenCandyLoadingPage
;   # Insert the OpenCandy offer pages
;   !insertmacro OpenCandyInsertAllOfferPages
;

!macro OpenCandyInsertAllOfferPages
	!insertmacro _OpenCandyOfferPageN 1
	!insertmacro _OpenCandyOfferPageN 2
	!insertmacro _OpenCandyOfferPageN 3
	!insertmacro _OpenCandyOfferPageN 4
!macroend



;
; _OpenCandyExecOfferN
; --------------------
; This function is internal to this helper script. Do not call it from your own code.
;
; Usage:
;  Push <offer type>
;  Push <offer number>
;  Call _OpenCandyExecOfferN
;

Function _OpenCandyExecOfferN
	Exch $0 ; Offer number
	Exch
	Exch $1 ; Offer type
	${If} $0 > 0
	${AndIf} $0 <= $OCInitOffersRequested
		${If}   $1 == ${OC_OFFER_TYPE_NORMAL}
		${OrIf} $1 == ${OC_OFFER_TYPE_EMBEDDED}
			Push $r0
			Push $r1
			!insertmacro _OCArrayGetValue $OCArrayUseOfferPage   $0 $r0
			!insertmacro _OCArrayGetValue $OCArrayShownOfferPage $0 $r1
			${If}    ${OC_NSIS_TRUE} == $r0 # UseOfferPage
			${AndIf} ${OC_NSIS_TRUE} == $r1 # ShownOfferPage
				Push $2
				Push $3
				IntOp $3 $0 - 1
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy17(m, i)i ('$OCAPIGuid', r3).r2 ? c"
				${If} $2 = $1
					System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy10(m, i)i ('$OCAPIGuid', r3).r2 ? c"
					${If} $2 = ${OC_OFFER_CHOICE_ACCEPTED}
						Push $1
						${If} $1 == ${OC_OFFER_TYPE_NORMAL}
							StrCpy $1 ${OC_OFFER_TYPE_FILTER_NORMAL}
						${Else}
							StrCpy $1 ${OC_OFFER_TYPE_FILTER_EMBEDDED}
						${EndIf}
						System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy29(m, i, i)v ('$OCAPIGuid', $1, r3) ? c"
						Pop $1
					${EndIf}
				${EndIf}
				Pop $3
				Pop $2
			${EndIf}
			Pop $r1
			Pop $r0
		${EndIf}
	${EndIf}
	Pop $1
	Pop $0
FunctionEnd



;
; OpenCandyOnInstSuccess
; ----------------------
;
; This macro needs to be inserted in the .onInstSuccess callback function
; to signal a successful installation of the product and launch installation
; of recommended software accepted by the end user.
;
; If you do not use the .onInstSuccess NSIS callback function in your
; script already you must add it.
;
; Usage:
;
;   Function .onInstSuccess
;     # Signal successful installation, download and install accepted offers
;     !insertmacro OpenCandyOnInstSuccess
;   FunctionEnd
;

!macro OpenCandyOnInstSuccess
	!insertmacro _OpenCandyAPIInserted OpenCandyOnInstSuccess
	${If}    $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
		Push $r0
		Push $r1
		Push $r2
		Push $0
		${For} $0 1 $OCInitOffersRequested
			; Fallback for embedded mode
			!insertmacro _OCArrayGetValue $OCArrayHasPerformedExecOfferEmbedded $0 $r0
			!insertmacro _OCArrayGetValue $OCArrayUseOfferPage   $0 $r1
			!insertmacro _OCArrayGetValue $OCArrayShownOfferPage $0 $r2
			${If}    ${OC_NSIS_FALSE} == $r0 # HasPerformedExecOfferEmbedded
			${AndIf} ${OC_NSIS_TRUE}  == $r1 # UseOfferPage
			${AndIf} ${OC_NSIS_TRUE}  == $r2 # ShownOfferPage
				!insertmacro _OpenCandyDevModeMsg "Information: Using embedded mode fallback." ${OC_NSIS_FALSE} 0
				Push ${OC_OFFER_TYPE_EMBEDDED}
				Push $0
				Call _OpenCandyExecOfferN
				!insertmacro _OCArraySetValue $OCArrayHasPerformedExecOfferEmbedded $0 ${OC_NSIS_TRUE}
			${EndIf}
			Push ${OC_OFFER_TYPE_NORMAL}
			Push $0
			Call _OpenCandyExecOfferN
		${Next}
		Push $1
		${For} $0 1 ${OC_MAX_OFFERS}
			IntOp $1 $0 - 1
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy19(m, i)i ('$OCAPIGuid', r1).n ? c"
		${Next}
		Pop $1
		Pop $0
		Pop $r2
		Pop $r1
		Pop $r0
		StrCpy $OCProductInstallSuccess ${OC_NSIS_TRUE}
		!ifdef OC_REBOOT_PROTOTYPE
		!ifdef OC_CALLBACKFN_REBOOT_QUERY
		${If} $OCSetPublisherMayReboot == ${OC_NSIS_TRUE}
			Call ${OC_CALLBACKFN_REBOOT_QUERY}
		${EndIf}
		!endif
		!endif
	${EndIf}
!macroend



;
; OpenCandyInstallEmbedded
; ------------------------
; This macro needs to be inserted in an install section that always runs
; to launch installation of recommended software accepted by the end user.
;
; Usage:
;
;   Section "-OpenCandyEmbedded"
;     # Handle offers the user accepted
;     # This section is hidden. It will always execute during installation
;     # but it won't appear on the component selection screen.
;     !insertmacro OpenCandyInstallEmbedded
;   SectionEnd
;

!macro OpenCandyInstallEmbedded
	!insertmacro _OpenCandyAPIInserted OpenCandyInstallEmbedded
	${If}    $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
		Push $r0
		Push $0
		${For} $0 1 $OCInitOffersRequested
			!insertmacro _OCArrayGetValue $OCArrayHasPerformedExecOfferEmbedded $0 $r0
			${If} ${OC_NSIS_FALSE} == $r0 # HasPerformedExecOfferEmbedded
				Push ${OC_OFFER_TYPE_EMBEDDED}
				Push $0
				Call _OpenCandyExecOfferN
				!insertmacro _OCArraySetValue $OCArrayHasPerformedExecOfferEmbedded $0 ${OC_NSIS_TRUE}
			${EndIf}
		${Next}
		Pop $0
		Pop $r0
	${EndIf}
!macroend



;
; OpenCandyOnGuiEnd
; -----------------
; This macro needs to be inserted in the .onGUIEnd callback function
; to properly unload the OpenCandy DLL. The DLL needs to remain loaded
; until then so that it can start the recommended software setup at the
; very end of the NSIS install process (depending on offer type).
;
; If you do not use the .onGUIEnd NSIS callback function in your
; script already you must add it.
;
; Your installer must not call any OpenCandy code after this macro
; code executes.
;
; Usage:
;
;   Function .onGUIEnd
;     # Inform the OpenCandy API that the installer is about to exit
;     !insertmacro OpenCandyOnGuiEnd
;   FunctionEnd
;

!macro OpenCandyOnGuiEnd
	!insertmacro _OpenCandyAPIInserted OpenCandyOnGuiEnd
	${If}    $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
		${If} $OCLoadingScreenActivity <> ${OC_LOADINGSCREEN_NOTACTIVE}
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy53(m)v ('$OCAPIGuid') ? c"
		${EndIf}
		Push $r0
		Push $0
		Push $1
		${For} $0 1 $OCInitOffersRequested
			IntOp $1 $0 - 1
			; Signal installation failures
			${If} $OCProductInstallSuccess == ${OC_NSIS_FALSE}
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy20(m, i)i ('$OCAPIGuid', r1).n ? c"
			${EndIf}
			; Clean up any attached screens
			!insertmacro _OCArrayGetValue $OCArrayOfferAttached $OCActiveOfferPage $r0
			${If} ${OC_NSIS_TRUE} == $r0 # OfferAttached
				System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy12(m, i)i ('$OCAPIGuid', r1).n ? c"
				!insertmacro _OCArraySetValue $OCArrayOfferAttached $0 ${OC_NSIS_FALSE}
			${EndIf}
		${Next}
		Pop $1
		Pop $0
		Pop $r0
	${EndIf}
	; Unload the client
	${If} $OCAPIGuid != ""
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy11(m)i ('$OCAPIGuid').n ? cu"
	${EndIf}
	; Free arrays
	!insertmacro _OpenCandyTeardownNSISAPI
!macroend



;
; OpenCandyOnUserAbort
; --------------------
; This macro can be inserted in the .onUserAbort callback function,
; or your MUI_CUSTOMFUNCTION_ABORT function, to inform the OpenCandy
; client that the user is attempting to abort the installation.
;
; Usage:
;
;   Function .onUserAbort
;     # Tell the OpenCandy client that the user is trying to abort the installation
;     !insertmacro OpenCandyOnUserAbort
;   FunctionEnd
;

!macro OpenCandyOnUserAbort
	${If}    $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
	${AndIf} $OCLoadingScreenActivity <> ${OC_LOADINGSCREEN_NOTACTIVE}
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy53(m)v ('$OCAPIGuid') ? c"
	${EndIf}
!macroend



;
; OCSetAdPolicy
; -------------
; This macro allows you to set ad policy flags that affect the presentation
; of OpenCandy offer screens. First combine each flag into a single bitmask,
; then pass the bitmask using the macro.
;
; Consult application notes provided by OpenCandy for valid flags to use in
; specific circumstances.
;
; Parameters:
;   FLAGS : A bitmask of valid OC_AP_* values Or'd together
;
; Usage:
;   # Enable "advertisement" terminology and a Decline control on OpenCandy offer screens
;   Push $0
;   StrCpy $0 ${OC_AP_BANNER_ADTEXT_ENABLE}
;   IntOp $0 $0 | ${OC_AP_DECLINE_SHOW_ONALL}
;   !insertmacro OCSetAdPolicy $0
;   Pop $0
;

!macro OCSetAdPolicy FLAGS
	StrCpy $OCAdPolicyFlags ${FLAGS}
	Push $0
	IntOp $0 $OCAdPolicyFlags & ${OC_AP_SKIPALL_SHOW_ONALL}
	${If} $0 <> 0
		IntOp $0 ${OC_AP_SKIPALL_SHOW_ONFIRST} ~
		IntOp $OCAdPolicyFlags $OCAdPolicyFlags & $0
	${EndIf}
	Pop $0
!macroend



;
; _OpenCandyGetSkipFmt
; --------------------
; This macro is internal to this helper script. Do not insert it in your
; own code.
;
; Determine if the instance requires a Skip control based on ad policy
; flags, offer readiness, and offer requirements.
;
; Usage:
;
;   Push <instance>
;   !insertmacro _OpenCandyGetSkipFmt
;   Pop <skip format> # One of OC_SKIPFMT_NOTSHOWN, OC_SKIPFMT_ATEXT, OC_SKIPFMT_BUTTON
;

!macro _OpenCandyGetSkipFmt
	Exch $0 ; Screen number
	Push $1 ; Display format (Result)
	Push $2 ; Skip required
	Push $3 ; Offer requires Skip button
	Push $4 ; Temp

	StrCpy $1 ${OC_SKIPFMT_NOTSHOWN}
	StrCpy $2 ${OC_NSIS_FALSE}
	StrCpy $3 ${OC_NSIS_FALSE}

	; If ad policy flags don't force skip on always using button display format,
	; need to also test offer requirements.
	StrCpy $4 ${OC_AP_SKIPALL_SHOW_ONALL}
	IntOp $4 $4 | ${OC_AP_SKIPALL_DRAW_BUTTON}
	Push $5
	IntOp $5 $OCAdPolicyFlags ^ $4
	IntOp $4 $5 & $4
	Pop $5
	${If} $4 <> 0
		Push "skip"          # Requirement
		Push ${OC_NSIS_TRUE} # Check global
		Push $0              # Screen
		!insertmacro _OCCheckOfferRequirement
		Pop $3
	${EndIf}

	; Check if Skip control is turned on always by policy or by offer
	IntOp $4 $OCAdPolicyFlags & ${OC_AP_SKIPALL_SHOW_ONALL}
	${If}   $4 <> 0
	${OrIf} $3 == ${OC_NSIS_TRUE}
		; Apply Skip control when more than one offer will be shown in the sequence from any provider
		IntOp $4 $OCAdPolicyFlags & ${OC_AP_SKIPALL_SHOW_EXCLUDEONLAST}
		${If} $4 = 0
			StrCpy $4 ${OC_AP_SEQUENCE_EXTOFFER_BEFOREOCOFFER}
		${Else}
			StrCpy $4 0
		${EndIf}
		IntOp $4 $4 | ${OC_AP_SEQUENCE_EXTOFFER_AFTEROCOFFER}
		IntOp $4 $OCAdPolicyFlags & $4
		${If} $4 <> 0
			; A qualifying publisher page exists
			StrCpy $2 ${OC_NSIS_TRUE}
		${Else}
			; Must have more than one OpenCandy offer to show Skip control
			IntOp $4 $OCAdPolicyFlags & ${OC_AP_SKIPALL_SHOW_EXCLUDEONLAST}
			${If} $4 = 0
				Push $5
				Push $r0
				IntOp $5 $0 - 1
				${For} $4 1 $5
					!insertmacro _OCArrayGetValue $OCArrayShownOfferPage $4 $r0
					${If} ${OC_NSIS_TRUE} == $r0 # ShownOfferPage
						StrCpy $2 ${OC_NSIS_TRUE}
						${Break}
					${EndIf}
				${Next}
				Pop $r0
				Pop $5
			${EndIf}
			${If} $2 != ${OC_NSIS_TRUE}
				Push $5
				Push $6
				IntOp $5 $0 + 1
				${For} $4 $5 $OCInitOffersRequested
					!insertmacro GetOCOfferStatus $4 ${OC_NSIS_FALSE}
					Pop $6
					${If} $6 != ${OC_OFFER_STATUS_NOOFFERSAVAILABLE}
						StrCpy $2 ${OC_NSIS_TRUE}
						${Break}
					${EndIf}
				${Next}
				Pop $6
				Pop $5
			${EndIf}
		${EndIf}
	${EndIf}

	${If} $2 == ${OC_NSIS_FALSE}
		; Skip might need to be displayed on the first offer screen to be shown
		; Check if Skip should always be displayed on the first of any OC screens
		IntOp $4 $OCAdPolicyFlags & ${OC_AP_SKIPALL_SHOW_ONFIRST}
		${If} $4 <> 0
			IntOp $4 $OCAdPolicyFlags & ${OC_AP_SEQUENCE_EXTOFFER_BEFOREOCOFFER}
			${If}    $OCInstanceDisplayedFirst = $0
			${OrIf}  $OCInstanceDisplayedFirst = ${OC_INSTANCE_DISPLAYEDFIRST_NOTSET}
			${AndIf} $4 = 0
				IntOp $4 $OCAdPolicyFlags & ${OC_AP_SEQUENCE_EXTOFFER_AFTEROCOFFER}
				${If} $4 <> 0
					StrCpy $2 ${OC_NSIS_TRUE}
				${Else}
					; Must have an OpenCandy offer after this one to show Skip control
					Push $5
					Push $6
					IntOp $5 $0 + 1
					${For} $4 $5 $OCInitOffersRequested
						!insertmacro GetOCOfferStatus $4 ${OC_NSIS_FALSE}
						Pop $6
						${If} $6 != ${OC_OFFER_STATUS_NOOFFERSAVAILABLE}
							StrCpy $2 ${OC_NSIS_TRUE}
							${Break}
						${EndIf}
					${Next}
					Pop $6
					Pop $5
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}

	${If} $2 == ${OC_NSIS_TRUE}
		; Skip will be displayed, determine the display format
		StrCpy $1 ${OC_SKIPFMT_ATEXT}
		IntOp $4 $OCAdPolicyFlags & ${OC_AP_SKIPALL_DRAW_BUTTON}
		${If} $4 <> 0
		${OrIf} $3 == ${OC_NSIS_TRUE}
			StrCpy $1 ${OC_SKIPFMT_BUTTON}
		${EndIf}
	${EndIf}

	StrCpy $0 $1
	Pop  $4
	Pop  $3
	Pop  $2
	Pop  $1
	Exch $0
!macroend



;
; _OpenCandyHandleSkip
; --------------------
; This macro is internal to this helper script. Do not insert it in your own code.
;
; Handle a Skip event from any source (OpenCandy or external), skipping the "from" page and onward
; and applying the OC_AP_SKIPALL_INCLUDES_PREVIOUS flag if set. This includes setting the
; skip reason in the client.
;
; Parameters:
;
;   InvokerPos     : The OpenCandy screen number that is the source of the event, or 0 for an external event
;   SkipOffersFrom : The lowest OpenCandy screen number affected by the Skip event
;
; Usage:
;
;   # Handle an internal skip from OpenCandy screen 2
;   !insertmacro _OpenCandyHandleSkip 2 2
;

!macro _OpenCandyHandleSkip InvokerPos SkipOffersFrom
	Push $0
	Push ${InvokerPos}
	Push ${SkipOffersFrom}
	Exch $1 ; Skip offers from
	Exch
	Exch $2 ; Invoker pos
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
		Push $3
		Push $r0
		Push $r1
		${For} $0 1 $OCInitOffersRequested
			!insertmacro _OCArrayGetValue $OCArraySkipState      $0 $r0
			!insertmacro _OCArrayGetValue $OCArrayShownOfferPage $0 $r1
			IntOp $3 $OCAdPolicyFlags & ${OC_AP_SKIPALL_INCLUDES_PREVIOUS}
			${If} $3 <> 0
			${OrIf} /* Offer pos */ $0 >= $1 /* Skip offers from */
				IntOp $3 $0 - 1
				; Instance is affected by Skip event
				${If} /* Offer pos */ $0 = $2 /* Invoker pos */ ; Skip acting on self

					${If} ${OC_SKIPSTATE_NOTSKIPPED} != $r0 # SkipState
						; Handling a prior skip that affects this screen
						${If} ${OC_SKIPSTATE_SKIPPED_EXTERNAL} == $r0 # SkipState
							System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy59(m, i, i)v ('$OCAPIGuid', ${OC_SKIPPED_3RDPARTYSKIP}, r3) ? c"
						${Else}
							System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy59(m, i, i)v ('$OCAPIGuid', ${OC_SKIPPED_OCSKIPNONOWNERSCREEN}, r3) ? c"
						${EndIf}
					${Else}
						; Skip originated from this screen
						!insertmacro _OCArraySetValue $OCArraySkipState $0 ${OC_SKIPSTATE_SKIPPED_OPENCANDY_OWNERSCREEN}
						System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy59(m, i, i)v ('$OCAPIGuid', ${OC_SKIPPED_OCSKIPOWNERSCREEN}, r3) ? c"
					${EndIf}
					!insertmacro _OCArraySetValue $OCArrayUseOfferPage $0 ${OC_NSIS_FALSE}
				${Else} ; Skip acting on other instances
					${If} ${OC_SKIPSTATE_NOTSKIPPED} == $r0 # SkipState
						${If} 0 = $2 /* Invoker pos */
							!insertmacro _OCArraySetValue $OCArraySkipState $0 ${OC_SKIPSTATE_SKIPPED_EXTERNAL}
						${Else}
							!insertmacro _OCArraySetValue $OCArraySkipState $0 ${OC_SKIPSTATE_SKIPPED_OPENCANDY_NONOWNERSCREEN}
						${EndIf}
						; Handle screens that have shown offers already immediately. Otherwise,
						; screens should call this routine, again acting upon themselves.
						${If} ${OC_NSIS_TRUE} == $r1 # ShownOfferPage
							${If} 0 = $2 /* Invoker pos */
								System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy59(m, i, i)v ('$OCAPIGuid', ${OC_SKIPPED_3RDPARTYSKIP}, r3) ? c"
							${Else}
								System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy59(m, i, i)v ('$OCAPIGuid', ${OC_SKIPPED_OCSKIPNONOWNERSCREEN}, r3) ? c"
							${EndIf}
							!insertmacro _OCArraySetValue $OCArrayUseOfferPage $0 ${OC_NSIS_FALSE}
						${EndIf}
					${EndIf}
				${EndIf}
			${EndIf}
		${Next}
		Pop $r1
		Pop $r0
		Pop $3
	${EndIf}
	Pop $2
	Pop $1
	Pop $0
!macroend



; OpenCandyHandleExternalSkip
; ---------------------------
; Insert this macro to inform OpenCandy that a Skip control has been
; clicked on a non-OpenCandy screen, and that OpenCandy screens must be skipped.
;
; If the ad policy flag OC_AP_SKIPALL_INCLUDES_PREVIOUS has been set, all
; OpenCandy screens will be skipped, otherwise only the screen specified and onwards
; will be skipped.
;
; Parameters:
;
;   SkipOffersFrom : When the ad policy flag OC_AP_SKIPALL_INCLUDES_PREVIOUS is not set,
;                    gives the lowest OpenCandy screen number to which the Skip action applies.
;
; Usage:
;
;   # An non-OpenCandy-owned Skip control was clicked prior to OpenCandy screen 1
;   # Skip all OpenCandy pages from screen 1 onwards.
;   !insertmacro OpenCandyHandleExternalSkip 1
;

!macro OpenCandyHandleExternalSkip SkipOffersFrom
	!insertmacro _OpenCandyHandleSkip 0 ${SkipOffersFrom}
!macroend



;
; _OpenCandyPerformSkipQuery
; --------------------------
; This macro is internal to this helper script. Do not insert it in your
; own code.
;
; Triggers the publisher's Skip Query callback, during which they should
; insert the macro OpenCandyHandleExternalSkip to inform us whether a Skip
; has occurred affecting OpenCandy screens.
;
; Publisher callback receives index of offer page triggering the callback.
;

!macro _OpenCandyPerformSkipQuery
	!ifdef OC_CALLBACKFN_SKIP_QUERY
	Exch $0
	${If} $0 > 0
	${AndIf} $0 <= $OCInitOffersRequested
		Push $r0
		!insertmacro _OCArrayGetValue $OCArraySkipState $0 $r0
		${If} ${OC_SKIPSTATE_NOTSKIPPED} == $r0 # SkipState
			Push $0
			Exch 2
			Pop $0
			Pop $r0
			Call ${OC_CALLBACKFN_SKIP_QUERY}
		${Else}
			Pop $r0
			Pop $0
		${EndIf}
	${Else}
		Pop $0
	${EndIf}
	!else
		Exch $0
		Pop $0
	!endif
!macroend



;
; _OCScreenCouldShow
; ------------------
; This macro is internal to this helper script. Do not insert it in your
; own code.
;
; Returns OC_NSIS_TRUE if a screen has been or could be shown, or
; OC_NSIS_FALSE otherwise.
;

!macro _OCScreenCouldShow OC_INSTANCE
	Push ${OC_INSTANCE}
	Exch $0 ; Screen
	Push $1 ; Result
	StrCpy $1 ${OC_NSIS_FALSE}
	Push $r0
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
	${AndIf} $0 > 0
	${AndIf} $0 <= $OCInitOffersRequested
		!insertmacro _OCArrayGetValue $OCArrayShownOfferPage $0 $r0
		${If} ${OC_NSIS_TRUE} == $r0 # ShownOfferPage
			StrCpy $1 ${OC_NSIS_TRUE}
		${Else}
			!insertmacro _OCArrayGetValue $OCArrayOfferIsEnabled $0 $r0
			${If} ${OC_NSIS_TRUE} == $r0 # OfferIsEnabled
				!insertmacro _OCArrayGetValue $OCArrayHasReachedOfferPage $0 $r0
				${If} ${OC_NSIS_FALSE} == $r0 # HasReachedOfferPage
					Push $2
					IntOp $2 $0 - 1
					System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy31(m, i, i)i ('$OCAPIGuid', ${OC_STATUS_QUERY_GENERAL}, r2).s ? c"
					Exch $2
					${If} $2 <> ${OC_OFFER_STATUS_NOOFFERSAVAILABLE}
						StrCpy $1 ${OC_NSIS_TRUE}
					${EndIf}
					Pop $2
					Pop $2
				${Else}
					!insertmacro _OCArrayGetValue $OCArrayUseOfferPage $0 $1
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}
	StrCpy $0 $1
	Pop  $r0
	Pop  $1
	Exch $0
!macroend



;
; _OCCheckOfferRequirement
; ------------------------
; This macro is internal to this helper script. Do not insert it in your
; own code.
;
; Tests whether a requirement applies to the specified instance, optionally
; applying global flags from other instances that have already shown an offer.
;
; Usage:
;
;   Push <requirement> # The case-sensitive requirement name
;   Push <global>      # Apply global flags from screens that have or might show? (OC_NSIS_TRUE or OC_NSIS_FALSE)
;   Push <screen>      # The OpenCandy offer screen number
;   !insertmacro _OCCheckOfferRequirement
;   Pop <result>       # OC_NSIS_TRUE if required for this screen, otherwise OC_NSIS_FALSE
;

!macro _OCCheckOfferRequirement
	Exch $0 ; Screen
	Exch 2
	Exch $1 ; Requirement
	Exch
	Exch $2 ; Global?
	Push $3 ; Result
	StrCpy $3 ${OC_NSIS_FALSE}
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
	${AndIf} $0 > 0
	${AndIf} $0 <= $OCInitOffersRequested
		Push $4
		Push $5
		Push $6
		IntOp $6 $0 - 1
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy63(m, m, m, *i, *i, i)v ('$OCAPIGuid', '$OCMemMapGuid', '$1', .r4, .r5, r6) ? c"
		${If} $4 = ${OC_REQUIRED_NO}
			${If} $2 == ${OC_NSIS_TRUE}
			${AndIf} $OCInitOffersRequested > 1
				; Check if we have a global true setting from another offer screen that overrides this result
				Push $7
				Push $8
				${For} $7 1 $OCInitOffersRequested
					${If} $7 = $0
						${Continue}
					${EndIf}
					!insertmacro _OCScreenCouldShow $7
					Pop $8
					${If} $8 == ${OC_NSIS_TRUE}
						IntOp $6 $7 - 1
						System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy63(m, m, m, *i, *i, i)v ('$OCAPIGuid', '$OCMemMapGuid', '$1', .r4, .r5, r6) ? c"
						${If} $5 <> ${OC_GLOBAL_NO}
						${AndIf} $4 <> ${OC_REQUIRED_NO}
							StrCpy $3 ${OC_NSIS_TRUE}
							${Break}
						${EndIf}
					${EndIf}
				${Next}
				Pop $8
				Pop $7
			${EndIf}
		${Else}
			StrCpy $3 ${OC_NSIS_TRUE}
		${EndIf}
		Pop $6
		Pop $5
		Pop $4
	${EndIf}
	StrCpy $0 $3
	Pop $3
	Pop $2
	Pop $1
	Exch $0
!macroend



;
; _OCDeclineButtonIsRequired
; --------------------------
; This macro is internal to this helper script. Do not insert it in your
; own code.
;
; Determines whether the instance must display a Decline control.
;
; Usage:
;
;   Push <screen> # The OpenCandy offer screen number
;   !insertmacro _OCDeclineButtonIsRequired <instance>
;   Pop <result>  # OC_NSIS_TRUE if a Decline control is required
;

!macro _OCDeclineButtonIsRequired
	Exch $0
	Push $1
	${If} $0 < 1
	${OrIf} $0 > $OCInitOffersRequested
		StrCpy $1 ${OC_NSIS_FALSE}
	${Else}
		; Check for setting that always displays the Decline control regardless of whether OpenCandy requires it to be present.
		IntOp $1 $OCAdPolicyFlags & ${OC_AP_DECLINE_SHOW_ONALL}
		${If} $1 <> 0
			StrCpy $1 ${OC_NSIS_TRUE}
		${Else}
			Push "decline"
			Push ${OC_NSIS_TRUE}
			Push $0
			!insertmacro _OCCheckOfferRequirement
			Pop $1
		${EndIf}
	${EndIf}
	StrCpy $0 $1
	Pop $1
	Exch $0
!macroend



;
; _OCBannerAdTextIsRequired
; -------------------------
; This macro is internal to this helper script. Do not insert it in your
; own code.
;
; Determines whether the instance must use "advertisement" terminology for banner text.
;
; Usage:
;
;   Push <screen> # The OpenCandy offer screen number
;   !insertmacro _OCBannerAdTextIsRequired <instance>
;   Pop <result> # OC_NSIS_TRUE if advertisement terminology should be used.
;

!macro _OCBannerAdTextIsRequired
	Exch $0
	Push $1
	${If} $0 < 1
	${OrIf} $0 > $OCInitOffersRequested
		StrCpy $1 ${OC_NSIS_FALSE}
	${Else}
		; Check for setting that always displays the advertisement nomenclature regardless of whether OpenCandy requires it to be present.
		IntOp $1 $OCAdPolicyFlags & ${OC_AP_BANNER_ADTEXT_ENABLE}
		${If} $1 <> 0
			StrCpy $1 ${OC_NSIS_TRUE}
		${Else}
			Push "advertisement"
			Push ${OC_NSIS_TRUE}
			Push $0
			!insertmacro _OCCheckOfferRequirement
			Pop $1
		${EndIf}
	${EndIf}
	StrCpy $0 $1
	Pop $1
	Exch $0
!macroend



; OpenCandyIsGoogleClientAppPolicyActive
; --------------------------------------
; Use this macro to determine if the Google Client App Policy has been
; indicated by OpenCandy offers that have already been displayed. The result
; is only valid once an OpenCandy page start function has been reached, e.g.
; during the OC_CALLBACKFN_ADPOLICY_QUERY or OC_CALLBACKFN_ADPOLICY_NOTIFY
; callbacks.
;
; Usage:
;   !insertmacro OpenCandyIsGoogleClientAppPolicyActive
;   Pop <result> # OC_NSIS_TRUE if the Google Client App Policy is indicated as active
;

!macro OpenCandyIsGoogleClientAppPolicyActive
	Push $0 ; Screen
	Push $1 ; Result
	StrCpy $1 ${OC_NSIS_FALSE}
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
		Push $2
		${For} $0 1 $OCInitOffersRequested
			!insertmacro _OCScreenCouldShow $0
			Pop $2
			${If} $2 == ${OC_NSIS_TRUE}
				Push "GoogleClientAppPolicy"
				Push ${OC_NSIS_FALSE}
				Push $0
				!insertmacro _OCCheckOfferRequirement
				Pop $1
				${If} $1 == ${OC_NSIS_TRUE}
					${Break}
				${EndIf}
			${EndIf}
		${Next}
		Pop $2
	${EndIf}
	StrCpy $0 $1
	Pop  $1
	Exch $0
!macroend



;
; OCSetPublisherMayReboot
; -----------------------
;
; Use this macro to indicate to OpenCandy that your installer may invoke
; a reboot after your product installation.
;
; Parameters:
;
;   MAY_REBOOT : Pass true if the installer may invoke a restart, otherwise
;                pass false.
;
; Usage:
;
;   # Inform OpenCandy that this installer may invoke a restart
;   !insertmacro OCSetPublisherMayReboot ${OC_NSIS_TRUE}
;

!ifdef OC_REBOOT_PROTOTYPE
!macro OCSetPublisherMayReboot MAY_REBOOT
	StrCpy $OCSetPublisherMayReboot ${MAY_REBOOT}
	${If}    $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized == ${OC_NSIS_TRUE}
		${If} ${MAY_REBOOT} == ${OC_NSIS_TRUE}
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy66(m,i)v ('$OCAPIGuid', ${OC_REBOOT_MAYREBOOT_ENABLED}) ? c"
		${Else}
			System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy66(m,i)v ('$OCAPIGuid', ${OC_REBOOT_MAYREBOOT_DISABLED}) ? c"
		${EndIf}
	${EndIf}
!macroend
!endif



;
; OCSetPublisherRebootNow
; -----------------------
; Inform OpenCandy the installer is about to trigger a reboot.
;
; Parameters:
;
;   MAX_WAIT_TIME : The maximum time, in seconds, that this call can
;                   block in order to send tracking.
;
; Usage:
;
;   # Inform OpenCandy the installer is about to trigger a reboot.
;   # Allow up to 4 seconds for any remaining tracking calls to complete
;   !insertmacro OCSetPublisherRebootNow 4
;

!ifdef OC_REBOOT_PROTOTYPE
!macro OCSetPublisherRebootNow MAX_WAIT_TIME
	StrCpy $OCProductInstallSuccess ${OC_NSIS_TRUE}
	${If} $OCNoCandy == ${OC_NSIS_FALSE}
	${AndIf} $OCHasBeenInitialized != ${OC_NSIS_TRUE}
		System::Call /NOUNLOAD "$PLUGINSDIR\OCSetupHlp.dll::OCPID973OpenCandy67(m,i)v ('$OCAPIGuid', ${MAX_WAIT_TIME}) ? c"
	${EndIf}
!macroend
!endif




!endif # !ifdef _OCSETUPHLP_NSH

; END of OpenCandy Helper Include file