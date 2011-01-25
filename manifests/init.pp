import "classes/*.pp"
import "defines/*.pp"

# Module to build and populate s3fs mounts:
class s3fs {

  include s3fs::build

  # Define directory under which all s3fs mounts will be done:
  s3fs::root { "/cloud": }

}
