SELECT endpoint_id, mode_start, (mode_start+(mode_duration*60)) as mode_end, (mode_duration*60) as mode_duration, label
INTO periods_new
FROM periods;

CREATE VIEW periods_view as 
SELECT endpoint_id, mode_start, mode_end, mode_duration, label,
		(SELECT reasons.reason 
		FROM reasons
		WHERE periods_new.endpoint_id=reasons.endpoint_id AND
		 reasons.event_time >= periods_new.mode_start AND reasons.event_time <= periods_new.mode_end
		LIMIT 1),
		(SELECT operators.operator_name 
		FROM operators
		WHERE periods_new.endpoint_id=operators.endpoint_id 
		 AND operators.login_time <= periods_new.mode_start AND operators.logout_time >= periods_new.mode_end),
		 (SELECT SUM(energy.kwh) as energy_sum
		  FROM energy
		  WHERE periods_new.endpoint_id=energy.endpoint_id AND
		  energy.event_time >= periods_new.mode_start AND energy.event_time <= periods_new.mode_end)
FROM periods_new;