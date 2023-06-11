CREATE TRIGGER trigger_packages_changes
  AFTER INSERT OR UPDATE OR DELETE ON packages
  FOR EACH ROW EXECUTE FUNCTION trigger_packages_changes();
