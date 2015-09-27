/*
 * Touch+ Software
 * Copyright (C) 2015
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the Aladdin Free Public License as
 * published by the Aladdin Enterprises, either version 9 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Aladdin Free Public License for more details.
 *
 * You should have received a copy of the Aladdin Free Public License
 * along with this program.  If not, see <http://ghostscript.com/doc/8.54/Public.htm>.
 */

﻿package
{
	import flash.display.*;
	import flash.utils.*;
	import flash.external.*;
	import flash.events.*;
	
	public class DebugPage extends MovieClip
	{
		private var self = this;
		private var reading:Boolean = false;
		private var lines_array_old:Array = new Array();
		private var loaded:Boolean = false;
		private var loaded_old:Boolean = false;
		private var target_alpha_progress:int = 0;
		private var target_alpha_status:int = 0;
		private var error_screen_is_on:Boolean = false;

		public function DebugPage():void
		{
			progress_fan0.inner = false;
			progress_fan1.inner = true;

			progress_fan0.alpha = 0;
			progress_fan1.alpha = 0;
			status_text.alpha = 0;

			var active_name_old:String = "";

			self.addEventListener(Event.ENTER_FRAME, function(e:Event):void
			{
				if (Globals.active_name == "ButtonDebug" && active_name_old != Globals.active_name)
					read_log();

				active_name_old = Globals.active_name;

				if (Globals.active_name != "ButtonDebug")
					return;

				if (progress_fan0.alpha < 0.1 && loaded && progress_fan0.visible)
				{
					progress_fan0.visible = false;
					progress_fan1.visible = false;
					status_text.visible = false;
					Globals.menu_bar.activate_index(3);
				}
				else
				{
					loaded = progress_fan1.progress_percent_current >= 99 &&
						 progress_fan0.progress_percent_current >= 99 &&
						 progress_fan1.progress_percent == 100 &&
						 progress_fan0.progress_percent == 100;

					if (loaded && !loaded_old)
					{
						hide_progress();
						hide_status();
					}

					loaded_old = loaded;

					var current_alpha_progress:Number = progress_fan0.alpha;
					var alpha_diff_progress:Number = (target_alpha_progress - current_alpha_progress) / 10;
					progress_fan0.alpha += alpha_diff_progress;
					progress_fan1.alpha += alpha_diff_progress;

					var current_alpha_status:Number = status_text.alpha;
					var alpha_diff_status:Number = (target_alpha_status - current_alpha_status) / 10;
					status_text.alpha += alpha_diff_status;
				}

				if (error_screen_is_on)
					self.debug_page_background.nextFrame();
				else
					self.debug_page_background.prevFrame();
			});

			setInterval(function():void
			{
				if (Globals.active_name != "ButtonDebug")
					return;

				read_log();

			}, 1000);
		}

		public function read_log():void
		{
			if (!reading)
			{
				reading = true;
				Interop.call_js("ReadTextFile('c:/touch_plus_software_log.txt')", function(obj):void
				{
					var lines_array:Array = obj as Array;
					if (lines_array.length > lines_array_old.length)
					{
						for (var i:int = lines_array_old.length - 1; i < lines_array.length; ++i)
						{
							if (i == -1)
								continue;
							
							if (lines_array[i] != "")
								console_text.appendText(lines_array[i] + "\n");
						}
						
						console_text.scrollV = console_text.maxScrollV;
						lines_array_old = lines_array;
					}
					reading = false;
				});
			}
		}

		private function show_progress():void
		{
			progress_fan0.visible = true;
			progress_fan1.visible = true;
			target_alpha_progress = 1;
		}

		private function hide_progress():void
		{
			target_alpha_progress = 0;
		}

		private function show_status():void
		{
			status_text.visible = true;
			target_alpha_status = 1;
		}

		private function hide_status():void
		{
			target_alpha_status = 0;
		}

		public function reset_progress():void
		{
			progress_fan0.progress_percent = 0;
			progress_fan1.progress_percent = 0;
		}

		public function set_downloading_progress(percent:int):void
		{
			if (percent <= progress_fan1.progress_percent)
				return;

			progress_fan1.progress_percent = percent;
			show_progress();
		}

		public function set_loading_progress(percent:int):void
		{
			if (percent <= progress_fan0.progress_percent)
				return;

			progress_fan0.progress_percent = percent;
			show_progress();
		}

		public function set_status(_status:String):void
		{
			status_text.text = _status;
			show_status();
		}

		public function error_screen_on():void
		{
			error_screen_is_on = true;
		}

		public function error_screen_off():void
		{
			error_screen_is_on = false;
		}
	}
}