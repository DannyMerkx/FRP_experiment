#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy2 Experiment Builder (v1.82.01), March 26, 2015, at 10:58
If you publish work using this script please cite the relevant PsychoPy publications
  Peirce, JW (2007) PsychoPy - Psychophysics software in Python. Journal of Neuroscience Methods, 162(1-2), 8-13.
  Peirce, JW (2009) Generating stimuli for neuroscience using PsychoPy. Frontiers in Neuroinformatics, 2:10. doi: 10.3389/neuro.11.010.2008
"""
from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
import pickle
from psychopy import visual, core, data, event, logging, sound, gui, tools
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import random # used to create the trails at random
import sys
from os.path import expanduser
home = expanduser('~')
sys.path.append('C:/Users/Beheerder/Downloads/python')
#from access_midi import *

# connect to midi device for sending hardware markers
#midi_sender = init_midi('MIDISPORT 2x2 Port A')

# synonym function for conversion from cm to pixels
def toPix (cm):
    return tools.monitorunittools.cm2pix(cm,win.monitor)

# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)

# Store info about the experiment session
expName = u'myexp'  # from the Builder filename that created this script
expInfo = {'participant':'', 'session':'001'}
dlg = gui.DlgFromDict(dictionary=expInfo, title=expName)
if dlg.OK == False: core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
filename = _thisDir + os.sep + 'data/%s_%s_%s' %(expInfo['participant'], expName, expInfo['date'])

# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath=None,
    savePickle=True, saveWideText=True,
    dataFileName=filename)
#save a log file for detail verbose info
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp

# Start Code - component code to be run before the window creation

# Setup the Window
win = visual.Window(size=(800, 600), fullscr=False, screen=0, allowGUI=False, allowStencil=False,
    monitor='Lab', color=[0,0,0], colorSpace='rgb',
    blendMode='avg', useFBO=True,
    )
# store frame rate of monitor if we can measure it successfully
expInfo['frameRate']=win.getActualFrameRate()
if expInfo['frameRate']!=None:
    frameDur = 1.0/round(expInfo['frameRate'])
else:
    frameDur = 1.0/60.0 # couldn't get a reliable measure so guess

# Initialize components for Routine "trial" this component generates 30 trials, each
# consisting of  targets
variables=[]
# generate 30 random orientation gradients to be used as target orientations in the trials.
random.seed(45)
randomori=[random.randint(0,3)*90 for x in range (30)]
# creates the list called variables, a list containing 30 trails each consisting of 300 randomly
# places and oriented c's
for a in range (30):
 random.seed(a)
 # generates random orientations for the stimuli. 
 placeholder= [random.randint(0,3)*90 for x in range (600)]
 # Removes the orientations which equal the target for this trial,
 # since targets will be assigned their orientation separately
 orientationlist= [x for x in placeholder if x != randomori[a] ]
 # generaties random locations for stimuli. This needs to be higher
 # than the actual number of stimuli since many will be removed.
 Q = [random.randint(-60,60)/4 for x in range (1000)]
 R = [random.randint(-46,46)/4 for x in range (1000)]
 x=0
 # this loop removes stimuli that are to close to each other.
 # the eyetracker needs about 1cm of space between stimuli.
 while x < len(Q):
  y=x+1
  while y < len (Q):
   if (-1.2<= Q[x]-Q[y] <=1.2) and (-1.2 <= R[x]-R[y] <=1.2):
    Q.pop(y)
    R.pop(y)
    x-=1
    break
   y+=1
  x+=1
 print len(Q)
# trial generates 30 targets and trail 2 generates 270 non targets
 trial=[visual.TextStim(win=win, ori=randomori[a], name='text',
      text=u'c',    font=u'Arial',
      units='pix', pos=[toPix(Q[x]),toPix(R[x])], height=toPix(1), wrapWidth=None,
      color=[-1.000,-1.000,-1.000], colorSpace='rgb', opacity=1,
      depth=-1.0) for x in range (30)]
 trial2=[visual.TextStim(win=win, ori=orientationlist[x-30], name='text',
      text=u'c',    font=u'Arial',
      units='pix', pos=[toPix(Q[x]),toPix(R[x])], height=toPix(1), wrapWidth=None,
      color=[-1.000,-1.000,-1.000], colorSpace='rgb', opacity=1,
      depth=-1.0) for x in range (30, 200)]
 trial.extend(trial2)
 variables.append(trial)

# mouse event, since trails end by mouseclick
mouse = event.Mouse(win=win)
x, y = [None, None]
trialClock= core.Clock()
ISI = core.StaticPeriod(win=win, screenHz=expInfo['frameRate'], name='ISI')

# Initialize components for Routine "Pause". This component tells the participant 
# to take a break, lasting as long as they want.
PauseClock = core.Clock()
mouse_2 = event.Mouse(win=win)
x, y = [None, None]
text_3 = visual.TextStim(win=win, ori=0, name='text_3',
    text=u'Pause\n\nPress any mouse button when ready to continue',    font=u'Arial',
    units='cm', pos=[0, 0], height=2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)


# Initialize components for Routine "Target", this components displays to the participant
# what the next trails target orientation is
TargetClock = core.Clock()
text = visual.TextStim(win=win, ori=0, name='text',
    text=u'Your next target is',    font=u'Arial',
    units='cm', pos=[0, 5], height=1, wrapWidth=None,
    color=[-1.000,-1.000,-1.000], colorSpace='rgb', opacity=1,
    depth=0.0)
targetstim=[visual.TextStim(win=win,ori=randomori[x], name='text_2',
    text=u'c',    font=u'Arial',
    units='cm', pos=[0, 0], height=5, wrapWidth=None,
    color=[-1.000,-1.000,-1.000], colorSpace='rgb', opacity=1,
    depth=-1.0) for x in range (30)]

# the random order is printed in order to trace back the order trials were presented in
# N.B  change program to save this order in a file instead of printing
print randomori

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 

# create Expnr a shuffled list of nrs 0 to 30 in order to be able to call trials in a random
# order. Changing the seed allows you to generate a new random order for each participant
random.seed(int(expInfo['session']))
x= [[i] for i in range (30)]
random.shuffle(x)
Expnr=[x[i][0] for i in range (30)]


for z in range (30):
    #------Prepare to start Routine "Target"-------
    t = 0
    TargetClock.reset()  # clock 
    frameN = -1
    routineTimer.add(5.000000)
    # update component parameters for each repeat
    # keep track of which components have finished
    TargetComponents = []
    TargetComponents.append(text)
    TargetComponents.append(targetstim[Expnr[z]])
    for thisComponent in TargetComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED

    #-------Start Routine "Target"-------
    continueRoutine = True
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = TargetClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *text* updates
        if t >= 0.0 and text.status == NOT_STARTED:
            # keep track of start time/frame for later
            text.tStart = t  # underestimates by a little under one frame
            text.frameNStart = frameN  # exact frame index
            text.setAutoDraw(True)
        if text.status == STARTED and t >= (5.0-win.monitorFramePeriod*0.75): #most of one frame period left
            text.setAutoDraw(False)
        
        # *text_2* updates
        if t >= 0.0 and targetstim[z].status == NOT_STARTED:
            # keep track of start time/frame for later
            targetstim[Expnr[z]].tStart = t  # underestimates by a little under one frame
            targetstim[Expnr[z]].frameNStart = frameN  # exact frame index
            targetstim[Expnr[z]].setAutoDraw(True)
        if targetstim[Expnr[z]].status == STARTED and t >= (0.0 + (5.0-win.monitorFramePeriod*0.75)): #most of one frame period left
            targetstim[Expnr[z]].setAutoDraw(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in TargetComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()

#-------Ending Routine "Target"-------
    for thisComponent in TargetComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)

        #------Prepare to start Routine "trial"-------
    t = 0
    trialClock.reset()  # clock 
    frameN = -1
    # update component parameters for each repeat
    # setup some python lists for storing info about the mouse
    # keep track of which components have finished
    trialComponents = []
    trialComponents.append(ISI)
    for x in range (200):
     trialComponents.append(variables[Expnr[z]][x])
    trialComponents.append(mouse)
    for thisComponent in trialComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    
    #-------Start Routine "trial"-------
    # send midi marker
    value = z
    try:
     eyelinkmarker = send_midi_marker(midi_sender,'stimulus',z+1,'srresearch_eyelink1000')
     biosemimarker = send_midi_marker(midi_sender,'stimulus',z+1,'biosemi_active2')
    except:
     continueRoutine = True
    while continueRoutine:
        # get current time
        t = trialClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *text* updates
        for x in range (200):
         if t >= 1 and variables[Expnr[z]][x].status == NOT_STARTED:
            # keep track of start time/frame for later
            variables[Expnr[z]][x].tStart = t  # underestimates by a little under one frame
            variables[Expnr[z]][x].frameNStart = frameN  # exact frame index
            variables[Expnr[z]][x].setAutoDraw(True)
         if variables[Expnr[z]][x].status == STARTED and (mouse==PRESSED):
            variables[Expnr[z]][x].setAutoDraw(False)
        # *mouse* updates
        if t >= 0.0 and mouse.status == NOT_STARTED:
            # keep track of start time/frame for later
            mouse.tStart = t  # underestimates by a little under one frame
            mouse.frameNStart = frameN  # exact frame index
            mouse.status = STARTED
            event.mouseButtons = [0, 0, 0]  # reset mouse buttons to be 'up'
        if mouse.status == STARTED:  # only update if started and not stopped!
            buttons = mouse.getPressed()
            if sum(buttons) > 0:  # ie if any button is pressed
                # abort routine on response
                continueRoutine = False
        # *ISI* period
        if t >= 0.0 and ISI.status == NOT_STARTED:
            # keep track of start time/frame for later
            ISI.tStart = t  # underestimates by a little under one frame
            ISI.frameNStart = frameN  # exact frame index
            ISI.start(1)
        elif ISI.status == STARTED: #one frame should pass before updating params and completing
            ISI.complete() #finish the static period
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in trialComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    #-------Ending Routine "trial"-------
    for thisComponent in trialComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # send midi marker
    value = z
    try:
     eyelinkmarker = send_midi_marker(midi_sender,'stimulus',z+1,'srresearch_eyelink1000')
     biosemimarker = send_midi_marker(midi_sender,'stimulus',z+1,'biosemi_active2')
    except:
    # store data for thisExp (ExperimentHandler)

    # the Routine "trial" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    
    #------Prepare to start Routine "Pause"-------
    t = 0
    PauseClock.reset()  # clock 
    frameN = -1
    # update component parameters for each repeat
    # setup some python lists for storing info about the mouse_2
    # keep track of which components have finished
    PauseComponents = []
    PauseComponents.append(mouse_2)
    PauseComponents.append(text_3)
    for thisComponent in PauseComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    
    #-------Start Routine "Pause"-------
    continueRoutine = True
    while continueRoutine:
        # get current time
        t = PauseClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        # *mouse_2* updates
        if t >= 0.0 and mouse_2.status == NOT_STARTED:
            # keep track of start time/frame for later
            mouse_2.tStart = t  # underestimates by a little under one frame
            mouse_2.frameNStart = frameN  # exact frame index
            mouse_2.status = STARTED
            event.mouseButtons = [0, 0, 0]  # reset mouse buttons to be 'up'
        if mouse_2.status == STARTED:  # only update if started and not stopped!
            buttons = mouse_2.getPressed()
            if sum(buttons) > 0:  # ie if any button is pressed
                # abort routine on response
                continueRoutine = False
        
        # *text_3* updates
        if t >= 0.0 and text_3.status == NOT_STARTED:
            # keep track of start time/frame for later
            text_3.tStart = t  # underestimates by a little under one frame
            text_3.frameNStart = frameN  # exact frame index
            text_3.setAutoDraw(True)
        if text_3.status == STARTED and (mouse==PRESSED):
            text_3.setAutoDraw(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in PauseComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    #-------Ending Routine "Pause"-------
    for thisComponent in PauseComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # store data for thisExp (ExperimentHandler)
    x, y = mouse_2.getPos()
    buttons = mouse_2.getPressed()
    thisExp.addData('mouse_2.x', x)
    thisExp.addData('mouse_2.y', y)
    thisExp.addData('mouse_2.leftButton', buttons[0])
    thisExp.addData('mouse_2.midButton', buttons[1])
    thisExp.addData('mouse_2.rightButton', buttons[2])
    thisExp.nextEntry()
    # the Routine "Pause" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
win.close()
core.quit()
