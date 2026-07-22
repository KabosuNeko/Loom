#include <X11/XF86keysym.h>
static const unsigned int borderpx = 1;
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft = 0;    /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;        /* 0 means no systray */
static const unsigned int gappih    = 10;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 10;       /* vert inner gap between windows */
static const unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 10;       /* vert outer gap between windows and screen edge */
static const int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const unsigned int baropacity = 0xd0000000;
static const char *fonts[]          = { "Maple Mono NF:size=12" };
static const char dmenufont[]       = "Maple Mono NF:size=12";

static char normbgcolor[] = "#2e3440";
static char normbordercolor[] = "#3b4252";
static char normfgcolor[] = "#d8dee9";
static char selfgcolor[] = "#eceff4";
static char selbordercolor[] = "#81a1c1";
static char selbgcolor[] = "#2e3440";

static char *colors[][3] = {
	/*               fg            bg            border   */
	[SchemeNorm] = { normfgcolor,  normbgcolor,  normbordercolor },
	[SchemeSel]  = { selfgcolor,   selbgcolor,   selbordercolor  },
};

static char termcol0[]  = "#3b4252";
static char termcol1[]  = "#bf616a";
static char termcol2[]  = "#a3be8c";
static char termcol3[]  = "#ebcb8b";
static char termcol4[]  = "#81a1c1";
static char termcol5[]  = "#b48ead";
static char termcol6[]  = "#88c0d0";
static char termcol7[]  = "#e5e9f0";
static char termcol8[]  = "#4c566a";
static char termcol9[]  = "#bf616a";
static char termcol10[] = "#a3be8c";
static char termcol11[] = "#ebcb8b";
static char termcol12[] = "#81a1c1";
static char termcol13[] = "#b48ead";
static char termcol14[] = "#8fbcbb";
static char termcol15[] = "#eceff4";

static char *termcolor[] = {
	termcol0, termcol1, termcol2, termcol3,
	termcol4, termcol5, termcol6, termcol7,
	termcol8, termcol9, termcol10, termcol11,
	termcol12, termcol13, termcol14, termcol15,
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };
//static const char *tags[] = { "󰔈", "", "󰻝", "", "", "", "", "", "" };
static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            1,           -1 },
	{ "firefox",  NULL,       NULL,       0,            0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[T]",      tile },    /* first entry is default */
	{ "[M]",      monocle },
	{ "[@]",      spiral },
	{ "[\\]",     dwindle },
	{ "[D]",      deck },
	{ "[B]",      bstack },
	{ "[=]",      bstackhoriz },
	{ "[G]",      grid },
	{ "[#]",      nrowgrid },
	{ "[-]",      horizgrid },
	{ "[:]",      gaplessgrid },
	{ "|M|",      centeredmaster },
	{ ">M>",      centeredfloatingmaster },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ NULL,       NULL },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *dmenucmd[] = { "dmenu_run", "-c", "-l", "10", "-fn", dmenufont, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbgcolor, "-sf", selfgcolor, NULL };
static const char *termcmd[]  = { "st", NULL };
static const char *pcmancmd[]  = { "pcmanfm", NULL };
static const char *firefoxcmd[] = { "firefox", NULL };
static const char *clipboardcmd[]  = { "clipmenu", NULL };

static const Key keys[] = {
	/* push down/up */
	{ MODKEY|ShiftMask,           XK_j,      pushdown,       {0} },
	{ MODKEY|ShiftMask,           XK_k,      pushup,         {0} },
	/* Wallpaper switcher */
	{ Mod1Mask,                       XK_w,      spawn,          SHCMD("$HOME/.local/bin/wallpaper") },
	/* Audio Keys */
    { 0, XF86XK_AudioRaiseVolume, spawn, SHCMD("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+; notify-send -h string:x-canonical-private-synchronous:osd -t 1500 \"     Volume: $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')%\"") },
    { 0, XF86XK_AudioLowerVolume, spawn, SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-; notify-send -h string:x-canonical-private-synchronous:osd -t 1500 \"     Volume: $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')%\"") },
    { 0, XF86XK_AudioMute,        spawn, SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && notify-send -h string:x-canonical-private-synchronous:osd -t 1500 \"󰖁     Volume Muted\" || notify-send -h string:x-canonical-private-synchronous:osd -t 1500 \"     Volume: $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')%\"") },

    /* Brightness Keys */
    { 0, XF86XK_MonBrightnessUp,   spawn, SHCMD("brightnessctl set 2%+; BRI=$(brightnessctl get); MAX=$(brightnessctl max); notify-send -h string:x-canonical-private-synchronous:osd -t 1500 \"󰃠  Brightness: $((BRI * 100 / MAX))%\"") },
    { 0, XF86XK_MonBrightnessDown, spawn, SHCMD("brightnessctl set 2%-; BRI=$(brightnessctl get); MAX=$(brightnessctl max); notify-send -h string:x-canonical-private-synchronous:osd -t 1500 \"󰃟  Brightness: $((BRI * 100 / MAX))%\"") },

    { MODKEY|ShiftMask, XK_p, spawn, SHCMD("~/.local/bin/exit-menu") },

    { MODKEY|ShiftMask, XK_v, spawn,          {.v = clipboardcmd } },
    { MODKEY|ShiftMask, XK_c, spawn,          SHCMD("clipdel -d '.*' && notify-send 'Clipboard History Cleared!'") },

    /* Screenshot */
    { MODKEY,                       XK_s,      spawn,          SHCMD("~/.local/bin/screenshot") },
    { MODKEY|ShiftMask,             XK_s,      spawn,          SHCMD("~/.local/bin/screenshot full") },

    /* Screen recorder */
    { MODKEY|ShiftMask,             XK_r,      spawn,          SHCMD("~/.local/bin/recorder") },

    /* Rofi Scripts */
    { MODKEY, XK_r, spawn, SHCMD("~/.local/bin/repos") },
	{ MODKEY, XK_o, spawn, SHCMD("~/.local/bin/tmux") },

	/* My binds for spawning apps */
    { MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
    { MODKEY,                       XK_f,      togglefullscr,  {0} },
	{ MODKEY,                       XK_w,      spawn,          {.v = firefoxcmd } },
	{ MODKEY,             		    XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_e,      spawn,          {.v = pcmancmd } },
	/* toggling the dwm bar */
	{ MODKEY|Mod1Mask,              XK_b,      togglebar,      {0} },
	/* moving between windows */
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	/* I belive this is removing and adding master windows */
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_a,      incnmaster,     {.i = -1 } },
	/* increasing and decreasing the size of master windows */
	{ MODKEY,                       XK_g,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_h,      setcfact,       {.f = +0.25} },
	{ MODKEY|ShiftMask,             XK_l,      setcfact,       {.f = -0.25} },
	{ MODKEY|ShiftMask,             XK_o,      setcfact,       {.f =  0.00} },
	/* essientially swapping the master window with the window you are focused on */
	{ MODKEY,                       XK_z, 	   zoom,           {0} },
	/* vanitygaps gap binds */
	{ MODKEY|Mod1Mask,              XK_u,      incrgaps,       {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_u,      incrgaps,       {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_i,      incrigaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_i,      incrigaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_o,      incrogaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_o,      incrogaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_6,      incrihgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_6,      incrihgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_7,      incrivgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_7,      incrivgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_8,      incrohgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_8,      incrohgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_9,      incrovgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_9,      incrovgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_0,      togglegaps,     {0} },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_0,      defaultgaps,    {0} },
	/* Killing the focused window and whatever view is */
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,             			XK_q,      killclient,     {0} },
	/* layouts */
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} }, // tile
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[1]} }, // monocle
	{ MODKEY|ShiftMask,             XK_s,      setlayout,      {.v = &layouts[2]} }, // spiral
	{ MODKEY|ShiftMask,             XK_d,      setlayout,      {.v = &layouts[3]} }, // dwindle
	{ MODKEY,                       XK_c,      setlayout,      {.v = &layouts[7]} }, // grid
	{ MODKEY,                       XK_n,      setlayout,      {.v = &layouts[8]} }, // nrowgrid
	{ MODKEY,                       XK_v,      setlayout,      {.v = &layouts[9]} }, // horizgrid
	{ MODKEY,                       XK_e,      setlayout,      {.v = &layouts[10]} }, // gaplessgrid
	{ MODKEY,                       XK_x,      setlayout,      {.v = &layouts[13]} }, // floating
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} }, // Floating as you can tell
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	/* Monitor focus and moving windows between monitors (default DWM bindings) */
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	/* moving between "TAGS" or workspaces basically */
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	/* Killing dwm */
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
	/* Reload X resources */
	{ MODKEY, 						XK_F5, xrdb, {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
