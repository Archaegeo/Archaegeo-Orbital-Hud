function AxisCommand.composeAxisAccelerationFromThrottle(self, tags)

    if self.commandType ~= axisCommandType.byThrottle then
        self.system.logError('Trying to get a axis command by Throttle while not in by-Throttle mode')
        return vec3()
    end

    local axisThrottle = self.throttle

    local axisCRefDirection = vec3()
    local axisWorldDirection = vec3()
    local additionalAcceleration = vec3()

    if (self.commandAxis == axisCommandId.longitudinal) then
        axisCRefDirection = vec3(DUConstruct.getOrientationForward())
        axisWorldDirection = vec3(DUConstruct.getWorldOrientationForward())
    elseif (self.commandAxis == axisCommandId.vertical) then
        axisCRefDirection = vec3(DUConstruct.getOrientationUp())
        axisWorldDirection = vec3(DUConstruct.getWorldOrientationUp())
        -- compensates gravity?
        local worldGravity = vec3(self.core.getWorldGravity())
        local gravityDot = worldGravity:dot(axisWorldDirection)
        if utils.sign(axisThrottle) == utils.sign(gravityDot) then
            -- gravity is going in the same direction we want
        else
            -- gravity is going in the opposite direction we want
            additionalAcceleration = -vec3(self.core.getWorldGravity())
        end
    elseif (self.commandAxis == axisCommandId.lateral) then
        axisCRefDirection = vec3(DUConstruct.getOrientationRight())
        axisWorldDirection = vec3(DUConstruct.getWorldOrientationRight())
    else
        return vec3()
    end

    local inspace = self.control.getAtmosphereDensity()

    local maxKPAlongAxis = DUConstruct.getMaxThrustAlongAxis(tags, {axisCRefDirection:unpack()})

    local forceCorrespondingToThrottle = 0
    if (inspace > 0.0989) then    
        if (axisThrottle > 0) then
            local maxAtmoForceForward = maxKPAlongAxis[1]
            forceCorrespondingToThrottle = axisThrottle * maxAtmoForceForward
        else
            local maxAtmoForceBackward = maxKPAlongAxis[2]
            forceCorrespondingToThrottle = -axisThrottle * maxAtmoForceBackward
        end
    elseif (inspace > 0) then
        if (axisThrottle > 0) then
            local maxSpaceForceForward = maxKPAlongAxis[3]
            if maxKPAlongAxis[1] and maxKPAlongAxis[1] > maxSpaceForceForward then maxSpaceForceForward = maxKPAlongAxis[1] end
            forceCorrespondingToThrottle = axisThrottle * maxSpaceForceForward
        else
            local maxSpaceForceBackward = maxKPAlongAxis[4]
            if maxKPAlongAxis[2] and maxKPAlongAxis[2] > maxKPAlongAxis[4] then maxSpaceForceBackward = maxKPAlongAxis[2] end
            forceCorrespondingToThrottle = -axisThrottle * maxSpaceForceBackward
        end
    else
        if (axisThrottle > 0) then
            local maxSpaceForceForward = maxKPAlongAxis[3]
            forceCorrespondingToThrottle = axisThrottle * maxSpaceForceForward
        else
            local maxSpaceForceBackward = maxKPAlongAxis[4]
            forceCorrespondingToThrottle = -axisThrottle * maxSpaceForceBackward
        end
    end

    local accelerationCommand = forceCorrespondingToThrottle / self.mass

    local finalAcceleration = accelerationCommand * axisWorldDirection + additionalAcceleration

    self.system.addMeasure("dynamic", "acceleration", "command", accelerationCommand)
    self.system.addMeasure("dynamic", "acceleration", "intensity", finalAcceleration:len())

    return finalAcceleration
end