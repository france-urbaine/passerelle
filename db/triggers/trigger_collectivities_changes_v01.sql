CREATE TRIGGER trigger_collectivities_changes
AFTER INSERT OR UPDATE OR DELETE ON collectivities
FOR EACH ROW EXECUTE FUNCTION trigger_collectivities_changes();