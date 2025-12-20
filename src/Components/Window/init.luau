-- Services
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");

-- Variables
local Modal = (script.Parent.Parent);
local Buttons = (Modal.Components.Buttons);
local Mouse = (Players.LocalPlayer:GetMouse());

-- Modules
local Fusion = require(Modal.Packages.Fusion);
local Storage = require(Modal.Storage.Information);
local Scoper = require(Modal.Utilities.Scoper);
local Colors = require(Modal.Utilities.Colors);
local Transparency = require(Modal.Utilities.Transparency);
local Animate = require(Modal.Utilities.Animate);
local Notification = require(Modal.Components.Popups.Notification);

-- Functions
local Scope = (Storage.Scope);
local Children = (Fusion.Children);
local OnChange = (Fusion.OnChange);
local OnEvent = (Fusion.OnEvent);

-- Types
type Configuration = {
	Title: string,
	SubTitle: string,
	Size: UDim2?,
	Transparency: number,
	MinimumSize: Vector2?,
	MaximumSize: Vector2?,
	Icon: string,
	Parent: GuiObject,
}

-- Init
local Window = function(Settings: Configuration)
	local Dragging, DragInput, Start, StartPosition

	local TabScrollObject = Scope:Value();
	local UIListObject = Scope:Value();
	local BottomLeftObject = Scope:Value();
	local BottomRightObject = Scope:Value();
	
	local Minimized = Scope:Value(false);
	local Maximized = Scope:Value(false);
	local Closed = Scope:Value(false);
	
	local Window = ({
		Tabs = Scope:Value({}),
		CurrentTab = Scope:Value("None"),
		PopupActive = Scope:Value(false),	
		
		Title = Scope:Value(Settings.Title),
		SubTitle = Scope:Value(Settings.SubTitle),
		Icon = Scope:Value(Settings.Icon),
		
		Themes = {
			Mode = Scope:Value("Light"),
			Accent = Scope:Value(Color3.fromRGB(97, 155, 199)),
			WindowTransparency = Scope:Value(Settings.Transparency or 0),
			Background = {
				Rotation = Scope:Value(90),
				Color = Scope:Value(ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(239, 237, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
				})),
				
				Line = {
					Color = Scope:Value(Color3.fromRGB()),
					Transparency = Scope:Value(0.9),
				},
				
				OuterOutline = {
					Transparency = Scope:Value(0.4),
					Color = Scope:Value(Color3.fromRGB(0, 0, 0)),
					Rotation = Scope:Value(0),
				},
				
				InnerOutline = {
					Transparency = Scope:Value(0.45),
					Color = Scope:Value(Color3.fromRGB(255, 255, 255)),
					Rotation = Scope:Value(0),
				}
			},
			
			Text = {
				Title = {
					Color = Scope:Value(Color3.fromRGB(0, 0, 0)),
				},

				Description = {
					Color = Scope:Value(Color3.fromRGB(110, 110, 110)),
				}
			},

			Icons = {
				ActionButtons = {
					Color = Scope:Value(Color3.fromRGB(0, 0, 0)),
					Transparency = Scope:Value(0.7),
				}
			},
			
			Content = {
				Color = Scope:Value(Color3.fromRGB(251, 248, 255)),
				Rotation = Scope:Value(0),
				ScrollBarColor = Scope:Value(Color3.fromRGB(200, 200, 200)),
				
				InnerOutline = {
					Transparency = Scope:Value(0.9),
					Color = Scope:Value(Color3.fromRGB(0, 0, 0)),
					Rotation = Scope:Value(0),
				},
				
				OuterOutline = {
					Transparency = Scope:Value(1),
					Color = Scope:Value(Color3.fromRGB(0, 0, 0)),
					Rotation = Scope:Value(0),
				},
			},
			
			Component = {
				Color = Scope:Value(Color3.fromRGB(245, 242, 249)),
				Rotation = Scope:Value(0),
			},
			
			Controls = {
				Color = Scope:Value(Color3.fromRGB(235, 232, 239)),
				Outline = Scope:Value(Color3.fromRGB(227, 225, 231))
			},
		},
	});
	
	local Active = ({
		BottomLeft = Scope:Value(false);
		BottomRight = Scope:Value(false);
		FocusedBottomLeft = Scope:Value(false);
		FocusedBottomRight = Scope:Value(false);
	})
		
	local MousePos, Size, UIPos, Type = nil, nil, nil
	local Minimum = (Settings.MinimumSize or Vector2.new(100, 100));
	local Maximum = (Settings.MaximumSize or Vector2.new(9e9, 9e9));
	
	local WindowSize = Scope:Value(Settings.Size or UDim2.fromOffset(520, 300));
	local WindowPosition = Scope:Value(UDim2.fromScale(0.5, 0.5));

	local Tab = require(script.Tab)(Window);
	local Component; Component = Scope:New "Frame" {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(250, 250, 250),
		ClipsDescendants = true,
		Parent = Settings.Parent or Storage.ScreenGuis.Window,
		Name = "_Window",
		
		Visible = Scope:Computed(function(Use)
			return (not Use(Closed));
		end),
		
		Position = Animate(function(Use)
			local IsMaximized = Use(Maximized);
			return (IsMaximized and UDim2.fromScale(0.5, 0.5)) or Use(WindowPosition)
		end, 30, 1),
		
		Size = Animate(function(Use)
			local CurrentSize = Use(WindowSize);
			local IsMinimized = Use(Minimized);
			local IsMaximized = Use(Maximized);
			return (IsMaximized and UDim2.fromScale(1, 1)) or (IsMinimized and UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset, 0, 55)) or CurrentSize
		end, 30, 1),

		[Children] = {
			Scope:New "UIGradient" {
				Name = "UIGradient",
				Color = Colors.SetupTheme(Window.Themes.Background.Color),
				Rotation = Window.Themes.Background.Rotation,
			},

			Scope:New "Frame" {
				Name = "Holder",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0.5, 0, 0, 55),
				ZIndex = 2,
				Size = UDim2.new(1, -10, 1, -60),
				
				Visible = Scope:Computed(function(Use)
					return (not Use(Minimized));
				end),
				
				[Children] = {
					Scope:New "UICorner" {
						Name = "UICorner",
						CornerRadius = UDim.new(0, 15),
					},

					Scope:New "UIStroke" {
						Name = "UIStroke",
						BorderStrokePosition = Enum.BorderStrokePosition.Inner,
						Color = Color3.fromRGB(255, 255, 255),

						[Children] = {
							Scope:New "UIGradient" {
								Name = "UIGradient",
								Color = Colors.SetupTheme(Window.Themes.Content.InnerOutline.Color),
								Transparency = Colors.SetupTheme(Window.Themes.Content.InnerOutline.Transparency, true),
								Rotation = Window.Themes.Content.InnerOutline.Rotation,
							},
						}
					},
					
					Scope:New "UIGradient" {
						Name = "UIGradient",
						Color = Colors.SetupTheme(Window.Themes.Content.Color),
						Rotation = Window.Themes.Content.Rotation,
					},
					
					Scope:New "UIStroke" {
						Name = "UIStroke",
						Thickness = 0.5,
						Color = Color3.fromRGB(255, 255, 255),

						[Children] = {
							Scope:New "UIGradient" {
								Name = "UIGradient",
								Color = Colors.SetupTheme(Window.Themes.Content.OuterOutline.Color),
								Transparency = Colors.SetupTheme(Window.Themes.Content.OuterOutline.Transparency, true),
								Rotation = Window.Themes.Content.OuterOutline.Rotation,
							},
						}
					},
					
					Scope:ForPairs(Window.Tabs, function(Use, Scope, Index, Value)
						return Tab.CreateScrollingFrame(Use, Scope, Index, Value);
					end)
				}
			},

			Scope:New "UIStroke" {
				Name = "UIStroke",
				Thickness = 2,
				Color = Color3.fromRGB(255, 255, 255),
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,
				
				[Children] = {
					Scope:New "UIGradient" {
						Name = "UIGradient",
						Color = Colors.SetupTheme(Window.Themes.Background.InnerOutline.Color),
						Transparency = Colors.SetupTheme(Window.Themes.Background.InnerOutline.Transparency, true),
						Rotation = Window.Themes.Background.InnerOutline.Rotation,
					},
				}
			},

			Scope:New "Folder" {
				Name = "Assets",

				[Children] = {
					Scope:New "ImageLabel" {
						Name = "Mica",
						ImageColor3 = Color3.fromRGB(0, 0, 0),
						ScaleType = Enum.ScaleType.Tile,
						ImageTransparency = 0.95,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Image = "rbxassetid://9968344105",
						TileSize = UDim2.new(0, 100, 0, 100),
						ZIndex = 1000,
						Size = UDim2.new(1, 0, 1, 0),

						[Children] = {
							Scope:New "UICorner" {
								Name = "UICorner",
								CornerRadius = UDim.new(0, 20),
							},
						}
					},
				}
			},

			Scope:New "Frame" {
				Name = "Topbar",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				ZIndex = 2,
				Size = UDim2.new(1, 0, 0, 40),

				[Children] = {
					Scope:New "Folder" {
						Name = "Buttons",

						[Children] = {
							Scope:New "TextButton" {
								Name = "Maximize",
								FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
								TextTransparency = 1,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								TextSize = 14,
								Size = UDim2.new(0, 20, 0, 20),
								LayoutOrder = 1,

								[OnEvent "MouseButton1Click"] = function()
									local Old = Scoper.Unwrap(Maximized);
									Maximized:set(not Old);
									Minimized:set(false);
								end,
								
								[Children] = {
									Scope:New "ImageLabel" {
										Name = "Icon",
										ScaleType = Enum.ScaleType.Fit,
										ImageTransparency = Window.Themes.Icons.ActionButtons.Transparency,
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										AnchorPoint = Vector2.new(0.5, 0.5),
										Image = "rbxassetid://87693340107218",
										BackgroundTransparency = 1,
										Position = UDim2.new(0.5, 0, 0.5, 0),
										Size = UDim2.new(0.45, 0, 0.45, 0),
										ImageColor3 = Window.Themes.Icons.ActionButtons.Color
									},
								}
							},

							Scope:New "UIListLayout" {
								Name = "UIListLayout",
								VerticalAlignment = Enum.VerticalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Right,
								Padding = UDim.new(0, 10),
								SortOrder = Enum.SortOrder.LayoutOrder,
							},

							Scope:New "TextButton" {
								Name = "Minimize",
								FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
								TextTransparency = 1,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								TextSize = 14,
								Size = UDim2.new(0, 20, 0, 20),
								
								[OnEvent "MouseButton1Click"] = function()
									local Old = Scoper.Unwrap(Minimized);
									Minimized:set(not Old);
									Maximized:set(false);
								end,

								[Children] = {
									Scope:New "ImageLabel" {
										Name = "Icon",
										ScaleType = Enum.ScaleType.Fit,
										ImageTransparency = Window.Themes.Icons.ActionButtons.Transparency,
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										AnchorPoint = Vector2.new(0.5, 0.5),
										Image = "rbxassetid://107591031930333",
										BackgroundTransparency = 1,
										Position = UDim2.new(0.5, 0, 0.5, 0),
										Size = UDim2.new(0.45, 0, 0.45, 0),
										ImageColor3 = Window.Themes.Icons.ActionButtons.Color
									},
								}
							},

							Scope:New "TextButton" {
								Name = "Close",
								FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
								TextTransparency = 1,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								TextSize = 14,
								LayoutOrder = 2,
								Size = UDim2.new(0, 20, 0, 20),

								[OnEvent "MouseButton1Click"] = function()
									Closed:set(true);
								end,
								
								[Children] = {
									Scope:New "ImageLabel" {
										Name = "Icon",
										ScaleType = Enum.ScaleType.Fit,
										ImageTransparency = Window.Themes.Icons.ActionButtons.Transparency,
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										AnchorPoint = Vector2.new(0.5, 0.5),
										Image = "rbxassetid://103624613466093",
										BackgroundTransparency = 1,
										Position = UDim2.new(0.5, 0, 0.5, 0),
										Size = UDim2.new(0.45, 0, 0.45, 0),
										ImageColor3 = Window.Themes.Icons.ActionButtons.Color 
									},
								}
							},
						}
					},

					Scope:New "UIPadding" {
						Name = "UIPadding",
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10),
					},

					Scope:New "Folder" {
						Name = "Script",

						[Children] = {
							Scope:New "UIListLayout" {
								Name = "UIListLayout",
								VerticalAlignment = Enum.VerticalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, 8),
								FillDirection = Enum.FillDirection.Horizontal,
							},

							Scope:New "ImageLabel" {
								Name = "Logo",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								Image = Window.Icon,
								BackgroundTransparency = 1,
								Size = UDim2.new(0, 20, 0, 20),
							},
							
							Scope:New "Frame" {
								Size = UDim2.fromOffset(150, 25),
								LayoutOrder = 1,
								BackgroundTransparency = 1,

								[Children] = {
									Scope:New "UIListLayout" {
										Name = "UIListLayout",
										VerticalAlignment = Enum.VerticalAlignment.Center,
										HorizontalAlignment = Enum.HorizontalAlignment.Left,
										SortOrder = Enum.SortOrder.LayoutOrder,
										Padding = UDim.new(0, 0),
										FillDirection = Enum.FillDirection.Vertical,
									},
									
									Scope:New "TextLabel" {
										Name = "SubTitle",
										LayoutOrder = 1,
										FontFace = Font.new(
											"rbxassetid://12187365364",
											Enum.FontWeight.SemiBold,
											Enum.FontStyle.Normal
										),
										TextColor3 = Window.Themes.Text.Description.Color,
										Text = Window.SubTitle,
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										BackgroundTransparency = 1,
										TextSize = 12,
										RichText = true,
										AutomaticSize = Enum.AutomaticSize.X,
										Size = UDim2.new(0, 0, 0, 10),
									},

									Scope:New "TextLabel" {
										Name = "Title",
										FontFace = Font.new(
											"rbxassetid://12187365364",
											Enum.FontWeight.Bold,
											Enum.FontStyle.Normal
										),
										TextColor3 = Window.Themes.Text.Title.Color,
										Text = Window.Title,
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										TextSize = 13,
										BackgroundTransparency = 1,
										RichText = true,
										AutomaticSize = Enum.AutomaticSize.X,
										Size = UDim2.new(0, 0, 0, 10),

										[Children] = {
											Scope:New "UIPadding" {
												Name = "UIPadding",
												PaddingBottom = UDim.new(0, 1),
											},
										}
									},
								}
							}
						}
					},

					Scope:New "Frame" {
						Name = "Line",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Window.Themes.Background.Line.Color,
						BackgroundTransparency = Window.Themes.Background.Line.Transparency,
						Position = UDim2.new(0.5, 0, 0.5, -3),
						Size = UDim2.new(0.15, 0, 0, 3),

						[Children] = {
							Scope:New "UICorner" {
								Name = "UICorner",
								CornerRadius = UDim.new(1, 0),
							},
						}
					},

					TabScrollObject:set(Scope:New "ScrollingFrame" {
						Name = "Tabs",
						ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
						CanvasSize = UDim2.new(),
						ScrollBarImageTransparency = 0.89,
						ScrollBarThickness = 2,
						AnchorPoint = Vector2.new(0, 0.5),
						Selectable = false,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 1, 1),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						AutomaticCanvasSize = Enum.AutomaticSize.X,
						Size = UDim2.new(1, 0, 0, 20),
						
						[OnChange "AbsoluteWindowSize"] = function()
							local Self = Scoper.Unwrap(TabScrollObject);
							local AbsoluteSize = Self.AbsoluteWindowSize.X
							local CanvasSize = Self.AbsoluteCanvasSize.X
							local More = CanvasSize > AbsoluteSize
							
							Scoper.Unwrap(UIListObject).HorizontalAlignment = Enum.HorizontalAlignment[(More and "Left") or "Center"]
						end, 
						
						[Children] = {
							UIListObject:set(Scope:New "UIListLayout" {
								Name = "UIListLayout",
								VerticalAlignment = Enum.VerticalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								Padding = UDim.new(0, 15),
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							
							Scope:ForPairs(Window.Tabs, function(Use, Scope, Index, Value)
								return Tab.CreateTabButton(Use, Scope, Index, Value, Window);
							end)
						}
					}),
				}
			},

			Scope:New "UICorner" {
				Name = "UICorner",
				CornerRadius = UDim.new(0, 20),
			},
			
			Scope:New "Frame" {
				Name = "Resizers",
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				ZIndex = 100,
				Size = UDim2.new(1, 0, 1, 0),
				Visible = Scope:Computed(function(Use)
					return (not Use(Minimized));
				end),
				
				[Children] = {
					BottomLeftObject:set(Scope:New "TextButton" {
						Name = "BottomLeft",
						Active = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						AnchorPoint = Vector2.new(0, 1),
						Selectable = false,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 1, 0),
						TextTransparency = 1,
						ZIndex = 100,
						Size = UDim2.fromOffset(20, 20),
						
						[OnEvent "InputBegan"] = function(Input)
							if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
								Type = Scoper.Unwrap(BottomLeftObject);
								MousePos = Vector2.new(Mouse.X, Mouse.Y);
								Size = (Component.AbsoluteSize);
								UIPos = (Component.Position);
								Active.BottomLeft:set(true);
							end
						end,
						
						[OnEvent "InputEnded"] = function(Input)
							if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
								Type = nil
								Active.BottomLeft:set(false);
							end
						end,
						
						[OnEvent "MouseEnter"] = function()
							Active.FocusedBottomLeft:set(true);
						end,
						
						[OnEvent "MouseLeave"] = function()
							Active.FocusedBottomLeft:set(false);
						end,
						
						[Children] = {
							Scope:New "ImageLabel" {
								Name = "Icon",
								ImageColor3 = Window.Themes.Icons.ActionButtons.Color,
								Rotation = 90,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Image = "rbxassetid://132140133843415",
								BackgroundTransparency = 1,
								ZIndex = 100,
								Position = UDim2.new(0.65, 0, 0.37, 0),
								
								ImageTransparency = Animate(function(Use)
									local ActiveButton = Use(Active.BottomLeft);
									local Focused = Use(Active.FocusedBottomLeft); 
									return (ActiveButton and 0) or (Focused and 0.2) or 0.4
								end, 20, 1),

								Size = Animate(function(Use)
									local ActiveButton = Use(Active.BottomLeft); 
									local Focused = Use(Active.FocusedBottomLeft); 
									local Offset = (ActiveButton and 15) or (Focused and 16) or 18
									return UDim2.fromOffset(Offset, Offset); 
								end, 20, 1),
							},
						}
					}),

					BottomRightObject:set(Scope:New "TextButton" {
						Name = "BottomRight",
						Active = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						TextTransparency = 1,
						AnchorPoint = Vector2.new(1, 1),
						BackgroundTransparency = 1,
						Position = UDim2.new(1, 0, 1, 0),
						Selectable = false,
						ZIndex = 100,
						Size = UDim2.fromOffset(20, 20),
						
						[OnEvent "InputBegan"] = function(Input)
							if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
								Type = Scoper.Unwrap(BottomRightObject);
								MousePos = Vector2.new(Mouse.X, Mouse.Y);
								Size = (Component.AbsoluteSize);
								UIPos = (Component.Position);
								Active.BottomRight:set(true);
							end
						end,

						[OnEvent "InputEnded"] = function(Input)
							if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
								Type = nil
								Active.BottomRight:set(false);
							end
						end,
						
						[OnEvent "MouseEnter"] = function()
							Active.FocusedBottomRight:set(true);
						end,

						[OnEvent "MouseLeave"] = function()
							Active.FocusedBottomRight:set(false);
						end,
						
						[Children] = {
							Scope:New "ImageLabel" {
								Name = "Icon",
								ImageColor3 = Window.Themes.Icons.ActionButtons.Color,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Image = "rbxassetid://132140133843415",
								BackgroundTransparency = 1,
								ZIndex = 100,
								Position = UDim2.new(0.35, 0, 0.37, 0),
								
								ImageTransparency = Animate(function(Use)
									local ActiveButton = Use(Active.BottomRight);
									local Focused = Use(Active.FocusedBottomRight); 
									return (ActiveButton and 0) or (Focused and 0.2) or 0.4
								end, 20, 1),

								Size = Animate(function(Use)
									local ActiveButton = Use(Active.BottomRight); 
									local Focused = Use(Active.FocusedBottomRight); 
									local Offset = (ActiveButton and 15) or (Focused and 16) or 18
									return UDim2.fromOffset(Offset, Offset); 
								end, 20, 1),
							},
						}
					}),
				}
			},
			
			Scope:New "UIStroke" {
				Name = "UIStroke",
				Thickness = 0.5,
				Color = Color3.fromRGB(255, 255, 255),
				
				[Children] = {
					Scope:New "UIGradient" {
						Name = "UIGradient",
						Color = Colors.SetupTheme(Window.Themes.Background.OuterOutline.Color),
						Transparency = Colors.SetupTheme(Window.Themes.Background.OuterOutline.Transparency, true),
						Rotation = Window.Themes.Background.OuterOutline.Rotation,
					},
				}
			},
			
			Scope:New "TextButton" {
				Name = "Background",
				TextTransparency = 1,
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				Interactable = Window.PopupActive,
				ZIndex = 10,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = Animate(function(Use)
					local PopupActive = Use(Window.PopupActive);
					return PopupActive and 0.8 or 1
				end, 30, 1),

				[Children] = {
					Scope:New "UICorner" {
						Name = "UICorner",
						CornerRadius = UDim.new(0, 20),
					},
				}
			}
		}
	}
	
	local OpenButton = Scope:New "TextButton" {
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 100,
		Size = UDim2.new(0, 40, 0, 40),
		Parent = Storage.ScreenGuis.Window,
		Position = Animate(function(Use)
			local Shown = Use(Closed);
			return UDim2.new(0.5, 0, 0, (Shown and 20) or -50)
		end, 20, 1),

		[OnEvent "MouseButton1Click"] = function()
			Closed:set(false);
		end,

		[Children] = {
			Scope:New "UIGradient" {
				Name = "UIGradient",
				Color = Colors.SetupTheme(Window.Themes.Background.Color),
				Rotation = Window.Themes.Background.Rotation,
			},
			
			Scope:New "TextLabel" {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = Window.Title,
				TextColor3 = Window.Themes.Text.Title.Color,
				FontFace = Font.new("rbxassetid://11598289817", Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
				TextSize = 14,
				BackgroundTransparency = 1,
			},

			Scope:New "UICorner" {
				Name = "UICorner",
				CornerRadius = UDim.new(0, 20),
			},

			Scope:New "UIStroke" {
				Name = "UIStroke",
				Thickness = 0.5,
				Color = Color3.fromRGB(255, 255, 255),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,

				[Children] = {
					Scope:New "UIGradient" {
						Name = "UIGradient",
						Color = Colors.SetupTheme(Window.Themes.Background.OuterOutline.Color),
						Transparency = Colors.SetupTheme(Window.Themes.Background.OuterOutline.Transparency, true),
						Rotation = Window.Themes.Background.OuterOutline.Rotation,
					},
				}
			},

			Scope:New "UIPadding" {
				Name = "UIPadding",
				PaddingRight = UDim.new(0, 15),
				PaddingLeft = UDim.new(0, 15),
			},

			Scope:New "UIStroke" {
				Name = "UIStroke",
				Thickness = 2,
				Color = Color3.fromRGB(255, 255, 255),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,

				[Children] = {
					Scope:New "UIGradient" {
						Name = "UIGradient",
						Color = Colors.SetupTheme(Window.Themes.Background.InnerOutline.Color),
						Transparency = Colors.SetupTheme(Window.Themes.Background.InnerOutline.Transparency, true),
						Rotation = Window.Themes.Background.InnerOutline.Rotation,
					},
				}
			},
		}
	}
	
	-- Setup
	Transparency.Add(Component);
	Transparency.Add(OpenButton);
	
	Window.Object = (Component);
	Transparency.ControlTransparency(Component, 0.25, Scoper.Unwrap(Window.Themes.WindowTransparency));

	Scope:Observer(Minimized):onChange(function()
		local Minimize = Scoper.Unwrap(Minimized);
		Transparency.ControlTransparency(Component, 0.25, (Minimize and 0.5) or (Scoper.Unwrap(Window.Themes.WindowTransparency) or 0));
	end)
	
	Scope:Observer(Closed):onChange(function()
		local Value = Scoper.Unwrap(Closed);
		Transparency.ControlTransparency(OpenButton, 0.25, (Value and (Settings.Transparency or 0)) or 1);
	end)
	
	Scope:Observer(Window.Themes.WindowTransparency):onChange(function()
		local Value = Scoper.Unwrap(Window.Themes.WindowTransparency);
		local Minimize = Scoper.Unwrap(Minimized);
		Transparency.ControlTransparency(Component, 0.25, (Minimize and 0.5) or Value);
	end)
		
	-- Connections
	table.insert(Scope, Mouse.Move:Connect(function()
		if (Type) then
			local Delta = Vector2.new(Mouse.X, Mouse.Y) - MousePos
			
			if (MousePos and Size and UIPos) then
				local Mode = (function()
					if (Type.Name == "BottomLeft") then
						return ({ X = Vector2.new(-1, 0), Y = Vector2.new(0, 1) });
					else
						return ({ X = Vector2.new(1, 0), Y = Vector2.new(0, 1) });
					end
				end)()

				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y);
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y));

				local AnchorOffset = Vector2.new(Component.AnchorPoint.X * Size.X, Component.AnchorPoint.Y * Size.Y);
				local NewAnchorOffset = Vector2.new(Component.AnchorPoint.X * NewSize.X, Component.AnchorPoint.Y * NewSize.Y);
				local DeltaAnchorOffset = (NewAnchorOffset - AnchorOffset);
				local NewPosition = UDim2.new(UIPos.X.Scale, UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X, UIPos.Y.Scale, UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y);
				
				WindowSize:set(UDim2.new(0, NewSize.X, 0, NewSize.Y))
				WindowPosition:set(NewPosition)
			end
		end
	end))
	
	table.insert(Scope, Component.InputBegan:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and (not Type) then
			Dragging = (true);
			Start = (Input.Position);
			StartPosition = Scoper.Unwrap(WindowPosition);

			Input.Changed:Connect(function()
				if (Input.UserInputState == Enum.UserInputState.End) then
					Dragging = false
				end
			end)
		end
	end))

	table.insert(Scope, Component.InputChanged:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and (not Type) then
			DragInput = Input
		end
	end))

	table.insert(Scope, UserInputService.InputChanged:Connect(function(Input)
		if (Input == DragInput and Dragging) and (not Type) then
			local Delta = Input.Position - Start
			local Screen = workspace.CurrentCamera.ViewportSize
			local Absolute = Component.AbsoluteSize

			local PosX = StartPosition.X.Offset + Delta.X
			local PosY = StartPosition.Y.Offset + Delta.Y

			WindowPosition:set(UDim2.new(StartPosition.X.Scale, PosX, StartPosition.Y.Scale, PosY));
		end
	end))
	
	-- Library
	local Edit = ({ Object = (Component) });
	
	Edit.AddTab = function(self, Title: string)
		local Components = Scope:Value({});
		local Self = ({});
		
		Scoper.Add(Window.Tabs, {
			Title = Title,
			Components = Components,
		})
		
		Self.New = function(self, Type): (...any)
			return function(...)
				local Module = Buttons:FindFirstChild(Type);
				
				if (Module) then
					local Result = require(Module)(..., Window);
					Scoper.Add(Components, Result);
					return Result
				else
					error(`Invalid component type: { Type } (Modal)`);
				end
			end
		end
		
		return Self
	end
	
	Edit.SetTab = function(self, Title)
		Window.CurrentTab:set(Title);
	end
	
	Edit.SetTheme = function(self, NewTheme, Target)
		local Target = (Target or Window.Themes)

		if (typeof(NewTheme) == "string") then
			NewTheme = require(Modal.Storage.Themes:FindFirstChild(NewTheme));
		end

		for Name, Value in pairs(Target) do
			local Type = typeof(Value)

			if (NewTheme and NewTheme[Name] ~= nil) then
				if (Scoper.IsFusionValue(Value)) then
					Value:set(NewTheme[Name])
				elseif (Type == "table" and Name ~= "WindowTransparency") then
					Edit:SetTheme(NewTheme[Name], Target[Name])
				end 
			end
		end
	end
		
	Edit.SetTransparency = function(self, Amount)
		Window.Themes.WindowTransparency:set(Amount);
	end
	
	Edit.SetTitle = function(self, Title)
		Window.Title:set(Title);
	end
	
	Edit.SetSubTitle = function(self, SubTitle)
		Window.SubTitle:set(SubTitle);
	end
	
	Edit.SetIcon = function(self, Icon)
		Window.Icon:set(Icon);
	end
	
	Edit.Notify = function(self, Configuration)
		return Notification.new(Configuration, Window);
	end
	
	Edit.Destroy = function(self)
		Scope:doCleanup();
	end
	
	return Edit
end

return Window