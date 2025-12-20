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
	Description: string,
	Duration: number,
	Type: "Success" | "Error" | "Info",
}

-- Init
local Notification = ({});

Notification.new = function(Settings: Configuration, Window)
	local Scope = CurrentScope:innerScope({});
	local NotificationSize = Scope:Value(UDim2.fromOffset(240, 0));

	local Colors = require(Modal.Utilities.Colors)(Scope);
	local Palette = ({
		["Error"] = Color3.fromRGB(229, 51, 51),
		["Info"] = Color3.fromRGB(77, 163, 255),
		["Success"] = Color3.fromRGB(60, 179, 113),
	})
	
	local Icons = ({
		Success = ("rbxassetid://120659272678891"),
		Error = ("rbxassetid://89180847534855"),
		Info = ("rbxassetid://75441143875602"),
	})

	local Color = (Palette[Settings.Type or "Info"] or Palette.Info);
	local Component
	Component = Scope:New "Frame" {
		Name = "Notification",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = Storage.ScreenGuis.Notification.Holder,
		Size = Animate(function(Use)
			return Use(NotificationSize) + UDim2.fromOffset(2, 2)
		end, 20, 1, Scope),

		[Children] = {
			Scope:New "Frame" {
				Name = "Notification",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ClipsDescendants = true,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5) - UDim2.fromOffset(2, 0),
				Size = UDim2.fromOffset(210, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = {
					Scope:New "ImageLabel" {
						Name = "Close",
						ImageColor3 = Window.Themes.Icons.ActionButtons.Color,
						ScaleType = Enum.ScaleType.Fit,
						ImageTransparency = Window.Themes.Icons.ActionButtons.Transparency,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						AnchorPoint = Vector2.new(1, 0),
						Image = "rbxassetid://103624613466093",
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -15, 0, 15),
						Size = UDim2.new(0, 8, 0, 8),
					},


					Scope:New "UIStroke" {
						Name = "UIStroke",
						Thickness = 1,
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

					Scope:New "TextButton" {
						Name = "Interact",
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
						TextColor3 = Color3.fromRGB(0, 0, 0),
						Text = "",
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						ZIndex = 5,
						TextSize = 14,
						Size = UDim2.fromScale(1, 1),

						[OnEvent "Activated"] = function()
							if (not Scoper.IsPoisoned(Scope)) then
								Transparency.ControlTransparency(Component, 0.25, 1);
								NotificationSize:set(UDim2.fromOffset(250, 0));

								task.delay(0.25, function()
									Scope:doCleanup();
								end)
							end
						end,
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

					Scope:New "UIGradient" {
						Name = "UIGradient",
						Color = Colors.SetupTheme(Window.Themes.Background.Color),
						Rotation = Window.Themes.Background.Rotation,
					},

					Scope:New "Frame" {
						Name = "Frame",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 35, 0, 0),
						ZIndex = 2,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, -65, 1, 0),

						[Children] = {
							Scope:New "TextLabel" {
								Name = "Title",
								TextWrapped = true,
								AnchorPoint = Vector2.new(0.5, 0),
								ZIndex = 3,
								Size = UDim2.new(1, 0, 0, 10),
								RichText = true,
								TextColor3 = Window.Themes.Text.Title.Color,
								Text = Settings.Title,
								TextSize = 14,
								BackgroundTransparency = 1,
								TextXAlignment = Enum.TextXAlignment.Left,
								Position = UDim2.new(0.5, 0, 0, 15),
								FontFace = Font.new(
									"rbxassetid://12187365364",
									Enum.FontWeight.Bold,
									Enum.FontStyle.Normal
								),
								AutomaticSize = Enum.AutomaticSize.Y,
								
								[Children] = {
									Scope:New "ImageLabel" {
										Name = "Icon",
										ImageColor3 = Color,
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										AnchorPoint = Vector2.new(0.5, 0.5),
										Image = (Icons[Settings.Type or "Info"] or Icons.Info),
										BackgroundTransparency = 1,
										ImageTransparency = 0,
										Position = UDim2.new(0, -15, 0.5, 0),
										Size = UDim2.new(0, 15, 0, 15),
									},
								}
							},

							Scope:New "TextLabel" {
								Name = "Description",
								FontFace = Font.new(
									"rbxassetid://12187365364",
									Enum.FontWeight.SemiBold,
									Enum.FontStyle.Normal
								),
								TextTransparency = 0.15,
								AnchorPoint = Vector2.new(0.5, 0.5),
								ZIndex = 2,
								Size = UDim2.new(1, 0, 0, 5),
								RichText = true,
								TextColor3 = Window.Themes.Text.Description.Color,
								Text = Settings.Description,
								TextWrapped = true,
								TextSize = 12,
								Position = UDim2.new(0.556, 0, 0.5, 7),
								BackgroundTransparency = 1,
								TextXAlignment = Enum.TextXAlignment.Left,
								AutomaticSize = Enum.AutomaticSize.Y,
								TextYAlignment = Enum.TextYAlignment.Top,
								
								[Children] = {
									Scope:New "Frame" {
										Name = "Line",
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundColor3 = Color,
										BackgroundTransparency = 0.7,
										Position = UDim2.new(0, -15, 0.5, 0),
										Size = UDim2.new(0, 3, 1, 3),
									},
								}
							},

							Scope:New "UIPadding" {
								PaddingTop = UDim.new(0, 14),
								PaddingBottom = UDim.new(0, 16),
							},

							Scope:New "UIListLayout" {
								VerticalAlignment = Enum.VerticalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, 0),
							},
						}
					},

					Scope:New "UICorner" {
						CornerRadius = UDim.new(0, 20),
					},
				}
			}
		}
	}
	
	local AbsoluteSize = Component.Notification.AbsoluteSize

	Transparency.Add(Component);
	Transparency.ControlTransparency(Component, 0, 1);
	
	task.wait();
	
	NotificationSize:set(UDim2.fromOffset(AbsoluteSize.X + 5, AbsoluteSize.Y + 5))
	Transparency.ControlTransparency(Component, 0.3, math.clamp(Scoper.Unwrap(Window.Themes.WindowTransparency) / 2, 0.15, 1));

	task.delay(Settings.Duration or 5, function()
		if (not Scoper.IsPoisoned(Scope)) then
			Transparency.ControlTransparency(Component, 0.25, 1);
			NotificationSize:set(UDim2.fromOffset(AbsoluteSize.X, 0));

			task.delay(0.25, function()
				Scope:doCleanup();
			end)
		end
	end)
end

return Notification