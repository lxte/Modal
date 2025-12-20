-- Services
local TextService = game:GetService("TextService");

-- Variables
local Modal = (script.Parent.Parent.Parent);

-- Modules
local Storage = require(Modal.Storage.Information);
local Fusion = require(Modal.Packages.Fusion);
local Animate = require(Modal.Utilities.Animate);
local Transparency = require(Modal.Utilities.Transparency);

-- Functions
local Scope = (Storage.Scope);
local Children = (Fusion.Children);
local OnEvent = (Fusion.OnEvent);

-- Init
local Tab = function(Window)
	local Components = ({});
	
	Components.CreateScrollingFrame = function(Use, Scope, Index, Value)
		local Object
		Object = Scope:New "ScrollingFrame" {
			Name = Value.Title,
			Active = true,
			ScrollBarThickness = 3,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 7),
			Size = UDim2.new(1, 0, 1, -14),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarImageColor3 = Window.Themes.Content.ScrollBarColor,

			[Children] = {
				Scope:New "UIPadding" {
					Name = "UIPadding",
					PaddingTop = Animate(function(Use)
						local Active = (Use(Window.CurrentTab) or "None") == Value.Title
						local Padding = (Active and 1) or 10
						return UDim.new(0, Padding);
					end, 15, 1),
				},

				Scope:New "UIListLayout" {
					Name = "UIListLayout",
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 7),
				},

				Scope:ForPairs(Value.Components, function(Use, Scope, Index, Component)
					task.spawn(function()
						local WindowTransparency = Fusion.peek(Window.Themes.WindowTransparency) or 0
												
						if (WindowTransparency) then
							Transparency.Add(Component);
							Transparency.ControlTransparency(Component, 0.15, WindowTransparency);
						end
					end)
					
					return Index, Component
				end)
			}
		}
		
		Transparency.Add(Object);
		Scope:Observer(Window.CurrentTab):onChange(function()
			local Peeked = Fusion.peek(Window.CurrentTab);
			local WindowTransparency = Fusion.peek(Window.Themes.WindowTransparency) or 0
			
			local Active = (Peeked or "None") == Value.Title
			local NewTransparency = (Active and WindowTransparency) or 1
			
			Transparency.ControlTransparency(Object, 0.15, NewTransparency) 
			Object.Visible = true
			
			task.delay(0.15, function()
				Object.Visible = Active
			end)
		end)
		
		return Index, Object
	end
	
	Components.CreateTabButton = function(Use, Scope, Index, Value, Window)
		local TextFont = Font.new("rbxassetid://12187365364", Enum.FontWeight.Heavy);
		local Bounds = TextService:GetTextSize(Value.Title, 16, Enum.Font.SourceSans, Vector2.new(10000, 10000))
		
		return Index, Scope:New "TextButton" {
			Size = UDim2.fromOffset(Bounds.X, 20),
			BackgroundTransparency = 1,
			
			[OnEvent "MouseButton1Click"] = function()
				Window.CurrentTab:set(Value.Title)
			end,
			
			[Children] = {
				Scope:New "TextLabel" {
					Name = "TabButton",
					TextColor3 = Window.Themes.Text.Title.Color,
					Text = Value.Title,
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.X,
					TextScaled = true,
					
					Size = Animate(function(Use)
						local IsSelected = (Use(Window.CurrentTab) or "None") == Value.Title
						local YSize = (IsSelected and 0.8) or 0
						
						return UDim2.fromScale(2, YSize);
					end, 30, 1),

					TextTransparency = Animate(function(Use)
						local IsSelected = (Use(Window.CurrentTab) or "None") == Value.Title
						return (IsSelected and 0.3) or 0.8
					end, 15, 1),
					
					FontFace = Scope:Computed(function(Use)
						local IsSelected = (Use(Window.CurrentTab) or "None") == Value.Title
						local Boldness = (IsSelected and Enum.FontWeight.Heavy) or Enum.FontWeight.SemiBold
						
						return TextFont
					end),
					
					[Children] = {
						Scope:New "UITextSizeConstraint" {
							MaxTextSize = 14,
							MinTextSize = 12,
						}
					}
				}
			}
		}
	end
	
	return Components
end

return Tab