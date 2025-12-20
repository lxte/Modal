-- Variables
local Modal = (script.Parent.Parent.Parent);
local Buttons = (Modal.Components.Buttons);

-- Modules
local Holder = require(Buttons.Holder);
local Fusion = require(Modal.Packages.Fusion);
local Storage = require(Modal.Storage.Information);
local Scoper = require(Modal.Utilities.Scoper);
local Transparency = require(Modal.Utilities.Transparency);
local Animate = require(Modal.Utilities.Animate);

-- Functions
local CurrentScope = Storage.Scope
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

-- Types
type Configuration = {
	Title: string,
	Options: {string},
	MultiDropdown: boolean,
	CurrentOptions: {string},
	Callback: (string | {string}) -> (),
}

-- Init
local Dropdown = ({});

Dropdown.new = function(Settings: Configuration, Window)
	-- Settings
	local Scope = CurrentScope:innerScope({});
	local Opened = Scope:Value(false);
	local SelectedItems = Scope:Value({});
	local SearchQuery = Scope:Value("");

	-- Modules
	local Colors = require(Modal.Utilities.Colors)(Scope);
	local FilteredOptions = Scope:Computed(function(Use)
		local Query = Use(SearchQuery):lower();
		if Query == "" then
			return Settings.Options;
		end

		local Filtered = {};
		for _, Option in Settings.Options do
			if Option:lower():find(Query, 1, true) then
				table.insert(Filtered, Option);
			end
		end
		return Filtered;
	end);
	
	local Add = function(Option, Selected)
		if (Selected) then
			local Old = Scoper.Unwrap(Selected);
			Selected:set(not Old);
		end

		local Current = Scoper.Unwrap(SelectedItems);
		local NewSelected = {};
		local Found = false;

		for _, Val in Current do
			if Val == Option then
				Found = true;
			else
				table.insert(NewSelected, Val);
			end
		end

		if not Found then
			table.insert(NewSelected, Option);
		end

		SelectedItems:set(NewSelected);
	end
	
	-- Component
	local Component
	Component = Scope:New "Frame" {
		Name = "Popup",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 11,
		Parent = Window.Object, 
		Size = Animate(function(Use)
			local WindowState = Use(Opened);
			local Scale = (WindowState and 0.85) or 0.8
			return UDim2.fromScale(Scale, Scale);
		end, 25, 0.7, Scope),

		[Children] = {
			Scope:New "UIGradient" {
				Name = "UIGradient",
				Color = Colors.Get(Window.Themes.Background.Color),
				Rotation = Scoper.Unwrap(Window.Themes.Background.Rotation),
			},

			Scope:New "Frame" {
				Name = "Holder",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0.5, 0, 0, 35),
				ZIndex = 2,
				Size = UDim2.new(1, -10, 1, -40),

				[Children] = {
					Scope:New "ScrollingFrame" {
						Name = "Home",
						ScrollBarImageColor3 = Scoper.Unwrap(Window.Themes.Content.ScrollBarColor),
						ScrollBarThickness = 0,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						CanvasSize = UDim2.new(1, 0, 0, 0),
						Position = UDim2.new(0, 0, 0, 0),
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						ScrollBarImageTransparency = 0.6,

						[Children] = {
							Scope:New "UIListLayout" {
								Name = "UIListLayout",
								SortOrder = Enum.SortOrder.LayoutOrder,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								Padding = UDim.new(0, 4),
							},

							Scope:New "UIPadding" {
								Name = "UIPadding",
								PaddingTop = UDim.new(0, 5),
								PaddingBottom = UDim.new(0, 5),
							},

							Scope:New "Frame" {
								Name = "SearchContainer",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 0.2,
								Size = UDim2.new(1, -10, 0, 35),
								Position = UDim2.new(0.5, 0, 0, 5),
								AnchorPoint = Vector2.new(0.5, 0),

								[Children] = {
									Scope:New "UICorner" {
										CornerRadius = UDim.new(1, 0),
									},
									
									Scope:New "UIGradient" {
										Name = "UIGradient",
										Rotation = Window.Themes.Component.Rotation,
										Color = Colors.Get(Window.Themes.Component.Color),
									},

									Scope:New "TextBox" {
										Name = "SearchBox",
										BackgroundTransparency = 1,
										Size = UDim2.new(1, -25, 1, 0),
										Position = UDim2.new(0, 10, 0, 0),
										Text = "",
										PlaceholderText = "Search options...",
										PlaceholderColor3 = Scoper.Unwrap(Window.Themes.Text.Title.Color),
										TextColor3 = Scoper.Unwrap(Window.Themes.Text.Title.Color),
										TextTransparency = 0.3,
										TextSize = 12,
										TextXAlignment = Enum.TextXAlignment.Left,
										ClearTextOnFocus = false,
										FontFace = Font.new(
											"rbxassetid://12187365364",
											Enum.FontWeight.Medium,
											Enum.FontStyle.Normal
										),

										[OnEvent "Changed"] = function(Property)
											if Property == "Text" then
												SearchQuery:set(Component.Holder.Home.SearchContainer.SearchBox.Text); 
											end
										end,
									},
								}
							},
							
							(Settings.MultiDropdown) and (Scope:New "TextButton" {
								Size = UDim2.new(1, -10, 0, 30),
								BackgroundColor3 = Scoper.Unwrap(Window.Themes.Accent),
								AutoButtonColor = false,
								Text = "",
								LayoutOrder = -1,
								
								[OnEvent "MouseButton1Click"] = function()
									local Selected = Scoper.Unwrap(SelectedItems);
									Settings.Callback(Selected);
									Window.PopupActive:set(false); 
									Opened:set(false);
									Transparency.ControlTransparency(Component, 0.3, 1);

									task.delay(0.3, function()
										Scope:doCleanup();
									end)
								end,

								[Children] = {
									Scope:New "UICorner" {
										CornerRadius = UDim.new(0.4, 0),
									},

									Scope:New "TextLabel" {
										Position = UDim2.fromScale(0.5, 0.5),
										AnchorPoint = Vector2.new(0.5, 0.5),
										Size = UDim2.fromScale(1, 1),
										BackgroundTransparency = 1,
										Text = "Submit",
										TextXAlignment = Enum.TextXAlignment.Center,
										TextColor3 = Color3.fromRGB(255, 255, 255),
										TextTransparency = 0.2,
										FontFace = Font.new(
											"rbxassetid://12187365364",
											Enum.FontWeight.Bold,
											Enum.FontStyle.Normal
										),
										TextSize = 12,
									}
								}
							}),
							
							Scope:Computed(function(Use)
								local Options = Use(FilteredOptions);
								local Buttons = ({});

								for _, Option in Options do
									local Default = table.find(Settings.CurrentOptions or {}, Option);
									local Selected = Scope:Value(Default);
									
									if (Default) then
										Add(Option, nil);
									end
									
									local Object; Object = Scope:New "TextButton" {
										Size = UDim2.new(1, -10, 0, 38),
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										AutoButtonColor = false,
										Text = "",

										[OnEvent "MouseEnter"] = function()
											Object.BackgroundTransparency = 0.5;
										end,

										[OnEvent "MouseLeave"] = function()
											Object.BackgroundTransparency = 0;
										end,

										[OnEvent "MouseButton1Down"] = function()
											if (not Settings.MultiDropdown) then
												Settings.Callback(Option);
												Window.PopupActive:set(false); 
												Opened:set(false);
												Transparency.ControlTransparency(Component, 0.3, 1);

												task.delay(0.3, function()
													Scope:doCleanup();
												end)
											else
												Add(Option, Selected);
											end
										end,

										[Children] = {
											Scope:New "UICorner" {
												CornerRadius = UDim.new(0, 10),
											},

											Scope:New "UIGradient" {
												Name = "UIGradient",
												Rotation = Window.Themes.Component.Rotation,
												Color = Colors.Get(Window.Themes.Component.Color),
											},

											Scope:New "Frame" {
												Name = "SelectIndicator",
												AnchorPoint = Vector2.new(0.5, 0.5),
												Size = UDim2.fromOffset(3, 10),
												BackgroundColor3 = Scoper.Unwrap(Window.Themes.Accent),
												
												BackgroundTransparency = Animate(function(Use)
													local IsSelected = Use(Selected);
													local IsOpened = Use(Opened);
													return (not IsOpened and 1) or (IsSelected and 0) or 1
												end, 18, 0.8, Scope),

												Position = Animate(function(Use)
													local IsSelected = Use(Selected);
													local IsOpened = Use(Opened);
													local X = (not IsOpened and -0.05) or (IsSelected and 0) or -0.05

													return UDim2.fromScale(X, 0.5)
												end, 18, 0.8, Scope),

												[Children] = {
													Scope:New "UICorner" {
														CornerRadius = UDim.new(1, 0),
													},
												}
											},

											Scope:New "TextLabel" {
												Position = UDim2.new(0, 12, 0.5, 0),
												AnchorPoint = Vector2.new(0, 0.5),
												Size = UDim2.fromScale(1, 1),
												BackgroundTransparency = 1,
												Text = Option,
												TextXAlignment = Enum.TextXAlignment.Left,
												TextColor3 = Scoper.Unwrap(Window.Themes.Text.Title.Color),
												TextTransparency = 0.2,
												FontFace = Font.new(
													"rbxassetid://12187365364",
													Enum.FontWeight.Bold,
													Enum.FontStyle.Normal
												),
												TextSize = 12,
											}
										}
									}
									
									table.insert(Buttons, Object);
								end

								return Buttons;
							end),
						}
					},

					Scope:New "UIStroke" {
						Name = "UIStroke",
						Color = Scoper.Unwrap(Window.Themes.Content.InnerOutline.Color),
						Transparency = Scoper.Unwrap(Window.Themes.Content.InnerOutline.Transparency),
						BorderStrokePosition = Enum.BorderStrokePosition.Inner,
					},

					Scope:New "UIGradient" {
						Name = "UIGradient",
						Color = Colors.Get(Window.Themes.Content.Color),
						Rotation = Scoper.Unwrap(Window.Themes.Content.Rotation),
					},

					Scope:New "UIStroke" {
						Name = "UIStroke",
						Thickness = 0.5,
						Color = Color3.fromRGB(255, 255, 255),

						[Children] = {
							Scope:New "UIGradient" {
								Name = "UIGradient",
								Color = Colors.Get(Window.Themes.Content.OuterOutline.Color),
								Transparency = Colors.Get(Window.Themes.Content.OuterOutline.Transparency, true),
								Rotation = Scoper.Unwrap(Window.Themes.Content.OuterOutline.Rotation),
							},
						}
					},

					Scope:New "UICorner" {
						Name = "UICorner",
						CornerRadius = UDim.new(0, 15),
					},
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
						Color = Colors.Get(Window.Themes.Background.InnerOutline.Color),
						Transparency = Colors.Get(Window.Themes.Background.InnerOutline.Transparency, true),
						Rotation = Scoper.Unwrap(Window.Themes.Background.InnerOutline.Rotation),
					},
				}
			},

			Scope:New "UIStroke" {
				Name = "UIStroke",
				Thickness = 0.5,
				Color = Color3.fromRGB(255, 255, 255),

				[Children] = {
					Scope:New "UIGradient" {
						Name = "UIGradient",
						Color = Colors.Get(Window.Themes.Background.OuterOutline.Color),
						Transparency = Colors.Get(Window.Themes.Background.OuterOutline.Transparency, true),
						Rotation = Scoper.Unwrap(Window.Themes.Background.OuterOutline.Rotation),
					},
				}
			},

			Scope:New "UIAspectRatioConstraint" {
				Name = "UIAspectRatioConstraint",
				AspectRatio = 0.75,
			},

			Scope:New "UICorner" {
				Name = "UICorner",
				CornerRadius = UDim.new(0, 20),
			},

			Scope:New "Frame" {
				Name = "Topbar",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				ZIndex = 2,
				Size = UDim2.new(1, 0, 0, 35),

				[Children] = {
					Scope:New "Folder" {
						Name = "Script",

						[Children] = {
							Scope:New "TextLabel" {
								Name = "Title",
								LayoutOrder = 1,
								FontFace = Font.new(
									"rbxassetid://12187365364",
									Enum.FontWeight.Bold,
									Enum.FontStyle.Normal
								),
								TextColor3 = Scoper.Unwrap(Window.Themes.Text.Title.Color),
								TextTransparency = 0.2,
								Text = Settings.Title,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								TextSize = 13,
								BackgroundTransparency = 1,
								RichText = true,
								AutomaticSize = Enum.AutomaticSize.X,
								Size = UDim2.new(0, 0, 0, 20),

								[Children] = {
									Scope:New "UIPadding" {
										Name = "UIPadding",
										PaddingBottom = UDim.new(0, 1),
									},
								}
							},

							Scope:New "UIListLayout" {
								Name = "UIListLayout",
								VerticalAlignment = Enum.VerticalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, 8),
								FillDirection = Enum.FillDirection.Horizontal,
							},
						}
					},

					Scope:New "Folder" {
						Name = "Buttons",

						[Children] = {
							Scope:New "UIListLayout" {
								Name = "UIListLayout",
								VerticalAlignment = Enum.VerticalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Right,
								Padding = UDim.new(0, 10),
								SortOrder = Enum.SortOrder.LayoutOrder,
							},

							Scope:New "TextButton" {
								Name = "Close",
								FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
								TextColor3 = Color3.fromRGB(0, 0, 0),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								TextTransparency = 1,
								TextSize = 14,
								Size = UDim2.new(0, 20, 0, 20),

								[OnEvent "MouseButton1Click"] = function()
									Window.PopupActive:set(false); 
									Opened:set(false);
									Transparency.ControlTransparency(Component, 0.3, 1);

									task.delay(0.3, function()
										Scope:doCleanup();
									end)
								end,

								[Children] = {
									Scope:New "ImageLabel" {
										Name = "Icon",
										ScaleType = Enum.ScaleType.Fit,
										ImageTransparency = Scoper.Unwrap(Window.Themes.Icons.ActionButtons.Transparency),
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										AnchorPoint = Vector2.new(0.5, 0.5),
										Image = "rbxassetid://103624613466093",
										BackgroundTransparency = 1,
										Position = UDim2.new(0.5, 0, 0.5, 0),
										Size = UDim2.new(0.45, 0, 0.45, 0),
										ImageColor3 = Scoper.Unwrap(Window.Themes.Icons.ActionButtons.Color)
									},
								}
							},
						}
					},

					Scope:New "UIPadding" {
						Name = "UIPadding",
						PaddingLeft = UDim.new(0, 12),
						PaddingRight = UDim.new(0, 12),
					},
				}
			},
		}
	}

	Transparency.Add(Component);
	Transparency.ControlTransparency(Component, 0, 1);

	Window.PopupActive:set(true); 
	Opened:set(true);
	Transparency.ControlTransparency(Component, 0.3, 0);
end

return Dropdown