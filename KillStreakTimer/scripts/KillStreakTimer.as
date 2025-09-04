package
{
   import Shared.*;
   import Shared.AS3.*;
   import Shared.AS3.Data.*;
   import Shared.AS3.Events.*;
   import com.adobe.serialization.json.*;
   import fl.motion.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.net.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import scaleform.gfx.*;
   
   public class KillStreakTimer extends MovieClip
   {
      
      public static const MOD_NAME:String = "KillStreakTimer";
      
      public static const MOD_VERSION:String = "1.0.0";
      
      public static const FULL_MOD_NAME:String = MOD_NAME + " " + MOD_VERSION;
      
      private static const TITLE_HUDMENU:String = "HUDMenu";
      
      private static const ICON_ADRENALINE:int = 48;
      
      private static const ZERO_POINT:Point = new Point(0,0);
      
      private var topLevel:* = null;
      
      private var HUDActiveEffectsWidget_mc:MovieClip = null;
      
      private var activeEffects:* = null;
      
      private var textFormat:TextFormat;
      
      private var timer:Timer;
      
      private var timer_tf:TextField;
      
      private var adrenalineTimer:Timer;
      
      private var lastAdrenalineStack:int = 0;
      
      private var adrenalineTime:int = 0;
      
      private var lastRenderTime:Number = 0;
      
      public function KillStreakTimer()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler,false,0,true);
      }
      
      public static function toString(param1:Object) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public static function ShowHUDMessage(param1:String) : void
      {
         GlobalFunc.ShowHUDMessage("[" + FULL_MOD_NAME + "] " + param1);
      }
      
      public function addedToStageHandler(param1:Event) : *
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler,false,0,true);
         this.topLevel = stage.getChildAt(0);
         if(Boolean(this.topLevel))
         {
            if(getQualifiedClassName(this.topLevel) == TITLE_HUDMENU)
            {
               this.init();
            }
         }
      }
      
      public function removedFromStageHandler(param1:Event) : *
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         if(this.timer)
         {
            this.timer.removeEventListener(TimerEvent.TIMER,this.displayEffectTimes);
         }
         if(this.adrenalineTimer)
         {
            this.adrenalineTimer.removeEventListener(TimerEvent.TIMER,this.adrenalineTimerTick);
         }
      }
      
      public function get elapsedTime() : Number
      {
         return getTimer() / 1000;
      }
      
      public function init() : void
      {
         this.timer_tf = new TextField();
         this.addChild(this.timer_tf);
         this.getActiveEffectsWidget();
         this.initTimer();
      }
      
      public function getActiveEffectsWidget() : void
      {
         if(this.topLevel && this.topLevel.RightMeters_mc && this.topLevel.RightMeters_mc.HUDActiveEffectsWidget_mc && this.topLevel.RightMeters_mc.HUDActiveEffectsWidget_mc.numChildren > 1)
         {
            this.HUDActiveEffectsWidget_mc = this.topLevel.RightMeters_mc.HUDActiveEffectsWidget_mc;
            this.activeEffects = this.HUDActiveEffectsWidget_mc.getChildAt(1);
         }
      }
      
      public function initTimer() : void
      {
         this.adrenalineTimer = new Timer(1000,30);
         this.adrenalineTimer.addEventListener(TimerEvent.TIMER,this.adrenalineTimerTick,false,0,true);
         this.timer = new Timer(20);
         this.timer.addEventListener(TimerEvent.TIMER,this.displayEffectTimes,false,0,true);
         this.timer.start();
      }
      
      public function adrenalineTimerTick() : void
      {
         this.adrenalineTime -= 1;
      }
      
      public function resetAdrenalineTimer() : void
      {
         this.adrenalineTime = 30;
         this.adrenalineTimer.reset();
         this.adrenalineTimer.start();
      }
      
      public function stopAdrenalineTimer() : void
      {
         this.lastAdrenalineStack = -1;
         this.adrenalineTime = 30;
         this.adrenalineTimer.stop();
      }
      
      public function displayEffectTimes() : void
      {
         var t1:Number;
         var hasAdrenaline:Boolean;
         var i:int;
         var effect:Object;
         var globalPos:Point;
         try
         {
            t1 = Number(getTimer());
            if(!this.activeEffects)
            {
               return;
            }
            hasAdrenaline = false;
            i = 0;
            while(i < this.activeEffects.numChildren)
            {
               effect = this.activeEffects.getChildAt(i);
               if(effect.visible)
               {
                  if(effect.getChildAt(3).currentFrame == ICON_ADRENALINE)
                  {
                     hasAdrenaline = true;
                     if(this.lastAdrenalineStack != effect.StackAmount && effect.StackAmount > 0)
                     {
                        this.resetAdrenalineTimer();
                        this.lastAdrenalineStack = effect.StackAmount;
                     }
                     Stack_mc = effect.Stack_mc;
                     if(this.textFormat == null)
                     {
                        this.textFormat = Stack_mc.StackAmount_tf.getTextFormat();
                        this.textFormat.bold = true;
                        TextFieldEx.setTextAutoSize(this.timer_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
                        this.timer_tf.defaultTextFormat = this.textFormat;
                        this.timer_tf.setTextFormat(this.textFormat);
                        this.timer_tf.background = true;
                        this.timer_tf.backgroundColor = 16777163;
                        this.timer_tf.border = true;
                        this.timer_tf.borderColor = 0;
                     }
                     globalPos = Stack_mc.BG_mc.localToGlobal(ZERO_POINT);
                     this.timer_tf.x = globalPos.x;
                     this.timer_tf.height = Stack_mc.BG_mc.height * 1.1;
                     this.timer_tf.y = globalPos.y - this.timer_tf.height;
                     this.timer_tf.text = this.adrenalineTime || "0";
                     this.timer_tf.width = Stack_mc.BG_mc.width * (Stack_mc.StackAmount_tf.length == 1 ? (this.timer_tf.text.length == 1 ? 1 : 1.4) : 1);
                     this.timer_tf.scaleX = this.HUDActiveEffectsWidget_mc.scaleX;
                     this.timer_tf.scaleY = this.HUDActiveEffectsWidget_mc.scaleY;
                     this.filters = effect.filters;
                     break;
                  }
               }
               i++;
            }
            this.timer_tf.visible = hasAdrenaline && Boolean(this.topLevel.RightMeters_mc.visible) && this.HUDActiveEffectsWidget_mc.visible;
            if(!hasAdrenaline)
            {
               this.stopAdrenalineTimer();
            }
            this.lastRenderTime = getTimer() - t1;
         }
         catch(e:*)
         {
         }
      }
   }
}

